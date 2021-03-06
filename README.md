coverEar
========

Used to copy files from other hosts because the normal copy would fail many times.

Have you ever met this when copying big file from a remote host:
![retry](retry.png)

Or have met this message when using the `copy` command:
    The specified network name is no longer available.

You might have to retry many times, this is really annoying. That's why this small script was born. It would retry automatically when the copying is complete, unless the retry count reaches the limit.

And this script would show the progress of the copy, it's very convenient. 

## Usage

    USAGE:
        coverEar.bat [/r <COUNT>] <SOURCE> <DEST>
        Copy one or more files to another location. It's the same with `copy` 
        command in `cmd.exe`. 

    OPTIONS:
           /r: If it's failed, there would be retries, the default retry times 
               is 10, you could set in the cmd line, e.g., 
                   coverEar.bat /r 50 savelog.zip D:\
       SOURCE: The source file(s) or folder that to be copied, wildcard could 
               be used, e.g.,:
                   coverEar.bat *.jpg D:\
         DEST: Specified the directory and/or filename for the new file(s)

