# get-file perl exit on broken file

- «find | file» even when using one perl processe take time
- I have this error

```console
thy@tdews1-256g:2025-11-03-space-evol$ get-files-type ssp.upload
error calling magic_file: JPEG image data, Exif standard: [TIFF image data, big-endian, direntries=12, height=3060, manufacturer=samsung, model=Galaxy A36 5G, orientation=upper-left, xresolution=180, yresolution=188, resolutionunit=2, datetime=2025:10:15 10:35:55, GPS-Data, width=4080] name use count (50) exceeded at /usr/lib/x86_64-linux-gnu/perl5/5.36/File/LibMagic.pm line 165, <> chunk 1604872.
```

- And comparing number of items from «find | stat» and «find | file»
  suggest the error exit the perl process (no files are deleted from
  this fileset)

```console
thy@tdews1-256g:tmp$ < ssp.upload-imn-stat.js.gz zcat | wc -l
1655902
thy@tdews1-256g:tmp$ < ssp.upload-type.js.gz zcat | wc -l
1604871
```

- First task for you: how to change file-type so that error are
  recorded but process continue after error (warning a test-error loop will be costly)

```yaml
- id: files-type
  perl: |
    BEGIN {
      $j = JSON::PP->new->utf8;
      $magic = File::LibMagic->new(follow_symlinks => 1, uncompress => 0)
    }
    chomp;
    my $info = $magic->info_from_filename($_);
    if ($info) {
      print $j->encode([$_, $info->{mime_type}, $info->{encoding}]), "\n";
    } else {
      print $j->encode([$_, undef, undef]), "\n";
    }
  sh: |
    (cd ${1:?} && find . -type f -print0 | perl -MJSON::PP -MFile::LibMagic -0 -ne "$perl")
  tt: |
    files-type /usr/share
    files-type ssp.upload
```

- Second task: is it possible and how easy it is to implement a n
  forking perl process to have a round robin paralle dispatch of file
  lib call (don't mix first and second task, give two different
  implementation)

# get-file killed by OOM killer

```console
thy@tdews1-256g:2025-11-03-space-evol$ time get-files-type profntr1-ssp
main: line 392: 129183 Broken pipe             find . -type f -print0
     129184 Killed                  | perl -MJSON::PP -MFile::LibMagic -0 -ne "$perl"

real	75m37.645s
user	0m25.323s
sys	0m32.633s
```

- from `syslog`

```
Nov  6 16:43:23 prostrg1 kernel: Out of memory: Kill process 129184 (perl) score 612 or sacrifice child
Nov  6 16:43:23 prostrg1 kernel: Killed process 129184 (perl) total-vm:1243096kB, anon-rss:534648kB, file-rss:0kB, shmem-rss:0kB
Nov  6 16:43:23 prostrg1 kernel: oom_reaper: reaped process 129184 (perl), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
```
- I suspect some memory leak
- But probably not related to number of file processed since I have
  bigger file set that completed without error
- So maybe a broke file provoke an excessive malloc request
- I can try to add a big swap
- But maybe you have a suggestion to contain the problem
  - That seems difficult because I can't see how perl could wrap a malloc in the C lib
  - But maybe we can catch a malloc error with a ulimit

> [!NOTE]
>
> - I'll lauch again to confirm that the memory use of perl in not growing slowly

```console
thy@tdews1-256g:tmp$ < profntr1-ssp-type.js.gz zcat | wc -l
622397
thy@tdews1-256g:tmp$ < ssp.upload-type.js.gz zcat | wc -l
1656315
```

# get-file has a memory leak

- I was wrong, the memory grows, slowly but more akin a memory leak than a abnormal file
- Maybe the memory link is linked to a specific file type (not
  occuring enuf to saturate mem on othersfile set
- So, the next step is to force dealloaction of magic obj (hoping that
  fix the leak) every 10k or so items
- If that don't fix we'll have to use xargs

```console
thy@tdews1-256g:tmp$ < profntr1-ssp-type.js.gz zcat | tail

gzip: stdin: unexpected end of file
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/7618c309d1565c6f558afee7f7d2c6fa","ERROR","error calling magic_file: cannot allocate 399928 bytes (Cannot allocate memory)\n"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/22a1cb95020a3c4af3b46e6219c91c73","ERROR","error calling magic_file: cannot allocate 409474 bytes (Cannot allocate memory)\n"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/20a39db21c212800da41262a6bc59a08","application/pdf","binary"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/e2ef4e2ebecbcbedb3182e9a3a0b959d","ERROR","error calling magic_file: cannot allocate 5466464 bytes (Cannot allocate memory)\n"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/095d48f6aa0a6aa6818e79b11cbdb710","application/pdf","binary"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/51c8e107d502b07d8aa3cf1b0b21d7ee","ERROR","error calling magic_file: cannot allocate 8388616 bytes (Cannot allocate memory)\n"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/dce8dc5ebbd2270924b61f837f97d556","ERROR","error calling magic_file: cannot allocate 380337 bytes (Cannot allocate memory)\n"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/d8c9a8a401590db8310480b1987fdc29","ERROR","error calling magic_file: cannot allocate 4490304 bytes (Cannot allocate memory)\n"]
["./ssp_ndf/upload/files_1731959368_by_group/59/2019/08/9ce4cd5c661ebf81efcbf152fd236ff2","application/pdf","binary"]
```

# Re-initializing libmagic object doesn't fix leak

- So let's go the `find -print0 | xargs -0 perl` way
- But with minimal implementation again
- Still keeping the exit on error catch
