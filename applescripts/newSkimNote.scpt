-- select_document: 在skim中选择指定名称的PDF文件
-- @param: String filename, 文件名(XXX.pdf)
-- @return: (a) 文件已经被打开，返回该文件
--          (b) 该文件没有被打开，返回false
on select_document(filename)
    tell application "Skim"
        documents where name contain filename
        if result is not {} then
            return item 1 of result
        end if
    end tell
    return false
end select_document

-- new_anthor_note: 在SKim中新建一个锚点笔记
-- @param: String title，笔记标题
-- @param: String content，笔记文本内容
-- [@param: the clipboard，笔记图片内容]
on new_anthor_note(note_title, note_content)
    activate application "Skim"
    tell application "System Events"
        keystroke "n" using {command down, option down}
    end tell
    tell application "Skim"
        windows where name contains "锚点笔记"
        if result is not {} then set index of item 1 of result to 1
    end tell
    tell application "System Events"
        tell process "Skim"
            tell (item 1 of windows)
                set value of text area 1 of scroll area 1 to note_content
                set value of text field 1 to note_title
                key code 48 --按一个tab，focus到图片上
                delay 0.2
                keystroke "v" using command down
            end tell
        end tell
    end tell
end new_anthor_note

-- argv 1: title
-- argv 2: filename of content file (text)
on run argv
    local title, content
    set title to item 1 of argv
    set content to read (POSIX file((do shell script "pwd.")&"/"&(item 2 of argv)))
    new_anthor_note(title, content)
end run
