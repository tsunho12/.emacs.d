on run argv
    set dir to (do shell script "pwd.")
    set fullpath to (dir & "/" & (item 1 of argv))
    set the clipboard to (read (POSIX file fullpath)as TIFF picture)
end run
