function descriptor()
    return {
    title = "Drawfee Stream Log",
    version = "1.0",
    author = "Amanda Ortman",
    url = "",
    shortdesc = "Drawfee Stream Log",
    description = "Track Drawfee streams",
    capabilities = {"menu", "input-listener", "meta-listener", "playing-listener"}
    }
end

--Temporary Current Tables for Updating Table
--quotesCurrentList = {}
--drawingsCurrentList = {}
--commentsCurrentList = {}

fileName = nil
quotesFile = nil
drawFile = nil
commentsFile = nil

function getVideoData() 
    input = vlc.object.input()
    fileName = vlc.input.item():name()
    fileDate = string.sub(fileName, 1, 8)
end

function errorDialog()
    fileErrorConsole = vlc.dialog("No file open.")
    fileErrorPopUp:add_label("Open Drawfee stream file.")
end

function activate()
    -- vlc.msg.dbg(vlc.config.userdatadir())
    if pcall(getVideoData) then
        getVideoData() 
        quotesFile =  vlc.config.userdatadir().."/drawfeeQuotes" .. fileDate .. ".csv"
        drawFile =  vlc.config.userdatadir().."/drawfeeDrawings" .. fileDate .. ".csv"
        commentsFile =  vlc.config.userdatadir().."/drawfeeComments" .. fileDate .. ".csv"
        createDialog()
        
        runQuotes()
        runDrawings()
        runCommments()

    else errorDialog()
    end
end

function deactivate()
    vlc.msg.dbg("Drawfee Stream Log deactivated.")
	-- what should be done on deactivation of extension
end

function playing_changed()
  vlc.msg.dbg(vlc.playlist.status())
end

function close()
	-- function triggered on dialog box close event
	-- for example to deactivate extension on dialog box close:
	vlc.deactivate()
end

-- Example: w = layout:add_label( "My Label", 2, 3, 4, 5 ) will create a label at row 3, col 2, with a relative width of 4, height of 5.
function createDialog()
    w = vlc.dialog("Drawfee Stream Log")

--Quotes
    quotes = w:add_label("Quotes",1,1,12,1)

    quotesList = w:add_list(1,2,60,1)

    setQuote = w:add_text_input("Where we",1,3,60,1)

    setSpeaker = w:add_text_input("Speaker",1,4,30,1)
    setTime = w:add_text_input("00:00:00",31,4,30,1)

    clearBtn = w:add_button("Clear",function() clearText(1)  end,1,5,3,1)
    deleteBtn = w:add_button("--",function() clearText(1)  end,4,5,3,1)
    setTimeBtn = w:add_button("Set Time",function() setTimeFnc(1) end,41,5,10,1)
    addQuoteBtn = w:add_button("Add Quote",function() addToList(setQuote, setSpeaker, nil, setTime, 1) end,51,5,10,1)

    lineBreak = w:add_label("<hr />",1,6,60,1)

--Drawings
    drawings = w:add_label("Drawings",1,7,12,1)

    drawingsList = w:add_list(1,8,60,1)

    setDraw = w:add_text_input("Spicy Kermit kissing",1,9,60, 1)

    setDrawer = w:add_text_input("Drawer",1,10,20,1)
    setUsername = w:add_text_input("Suggestor",21,10,20,1)
    setTime2 = w:add_text_input("00:00:00",41,10,20,1)

    
    clearBtn2 = w:add_button("Clear",function() clearText(2) end,1,11,3,1)
    deleteBtn2 = w:add_button("--",function() clearText(1)  end,4,11,3,1)
    setTimeBtn2 = w:add_button("Set Time",function() setTimeFnc(2) end,41,11,10,1)
    addDrawBtn = w:add_button("Add Drawing",function() addToList(setDraw, setDrawer, setUsername, setTime2, 2) end,51,11,10,1)

    lineBreak2 = w:add_label("<hr />",1,12,60,1)

--Comments
    comments = w:add_label("Comments",1,13,12,1)

    commentsList = w:add_list(1,14,60,1)
    
    addComment = w:add_text_input("Comment",1,15,30,1)
    setTime3 = w:add_text_input("00:00:00",31,15,30,1)

    clearBtn3 = w:add_button("Clear",function() clearText(3) end,1,16,3,1)
    deleteBtn3 = w:add_button("--",function() clearText(1)  end,4,16,4,1)
    setTimeBtn3 = w:add_button("Set Time",function() setTimeFnc(3) end, 41,16,10,1)
    addCommentBtn = w:add_button("Add Comment",function() addToList(addComment, nil, nil, setTime3, 3) end,51,16,10,1)    

    lineBreak3 = w:add_label("<hr />",1,17,60,1)

    pausePlayBtn = w:add_button("Pause/Play",pausePlayStatus,1,18,60,1)
end


function runQuotes()    
    local quotesCSV = io.open(quotesFile,r) --read only
    local quotesFormatted = {}
    --local tempHold = {}
    if (quotesCSV) then
        for lines in quotesCSV:lines() do --for each line in file
            if lines ~= nil then --if the lines exist 
                --tempHold = string.gsub(lines, "\n", "~~")
                --table.insert (quotesCurrentList, tempHold)
                quotesFormatted = string.gsub(lines, "&", "\t")
                quotesList:add_value(quotesFormatted)
            end
        end
        quotesCSV:close()
    end    
end


function runDrawings()
    local drawingsCSV = io.open(drawFile,r) --read only
    local drawsFormatted = {}
    --local tempHold = {}
    if (drawingsCSV) then --if drawing file exists
        for lines in drawingsCSV:lines() do --for each line in file
            if lines ~= nil then --if the lines exist 
                --tempHold = string.gsub(lines, "\n", "~~")
                --table.insert (drawingsCurrentList, tempHold)
                drawsFormatted = string.gsub(lines, "&", "\t")
                drawingsList:add_value(drawsFormatted)
            end
        end
        drawingsCSV:close()
    end
end


function runCommments()
    local commentsCSV = io.open(commentsFile,r) --read only
    local commentsFormatted = {}
    --local tempHold = {}
    if (commentsCSV) then
        for lines in commentsCSV:lines() do --for each line in file
            if lines ~= nil then --if the lines exist
                --tempHold = string.gsub(lines, "\n", "~~")
                --table.insert (commentsCurrentList, tempHold)
                commentsFormatted = string.gsub(lines, "&", "\t")
                commentsList:add_value(commentsFormatted)               
            end
        end
        commentsCSV:close()
    end
end


function addToList(a,b,c,d,e)
    local file2Append = {}
    local eList = {}
    local appendSubmission = {}

    if e==1 then
        file2Append = quotesFile
        eList = quotesList
        local getQuote = a:get_text()
        local getSpeaker = b:get_text()
        local getQuoteTime = d:get_text()    
        appendSubmission = getQuoteTime .. "&" .. getSpeaker .. "&" .. getQuote .. "\n"

    elseif e==2 then
        file2Append = drawFile
        eList = drawingsList
        local getDrawing = a:get_text()
        local getDrawer = b:get_text()
        local getUsername = c:get_text()
        local getDrawTime = d:get_text()    
        appendSubmission = getDrawTime .. "&" .. getDrawer .. "&" .. getUsername .. "&" .. getDrawing .. "\n"  

    elseif e==3 then
        file2Append = commentsFile
        eList = commentsList
        local getComment = a:get_text()
        local getCommentTime = d:get_text()    
        appendSubmission = getCommentTime .. "&" .. getComment .. "\n"   
    end

     if appendSubmission ~= nil then
        local file, err = io.open(file2Append,"a")
        if file==nil then
            print("Couldn't open file: ".. err)
        else
            file:write(appendSubmission)
            file:flush()
            file:close()
            eList:clear()
            if e==1 then runQuotes() end
            if e==2 then runDrawings() end
            if e==3 then runCommments() end
        end
    end
end


function clearText(b)
    if b==1 then
        setQuote:set_text("Quote")
        setSpeaker:set_text("Speaker")
        setTime:set_text("00:00:00")
    elseif b==2 then
        setDraw:set_text("Where we")
        setDrawer:set_text("Drawer")
        setUsername:set_text("Suggestor")
        setTime2:set_text("00:00:00")
    elseif b==3 then
        addComment:set_text("Comment")
        setTime3:set_text("00:00:00")
    end
end


function setTimeFnc(t)
    if t==1 then
        setTime:set_text(convertTime(vlc.var.get(input,"time")))
        pausePlayStatus(1)
    elseif t==2 then
        setTime2:set_text(convertTime(vlc.var.get(input,"time")))
        pausePlayStatus(1)
    elseif t==3 then
        setTime3:set_text(convertTime(vlc.var.get(input,"time")))
        pausePlayStatus(1)
    end
end

--[[ function deleteSelection(x,y) BRO IDK I QUIT
    local selection = y:get_selection()

    for a,b in ipairs(quotesCurrentList) do 
        if a==selection then
            a = nil  
            b = nil         
        else           
            vlc.msg.dbg(a,b)
        end
    end
end     ]]

function pausePlayStatus(x)
    if x==1 then
        if vlc.playlist.status() ~= "paused" then
            vlc.playlist.pause()
        end
    else 
        if vlc.playlist.status() ~= "paused" then
            vlc.playlist.pause()
        else vlc.playlist.play()
        end
    end
end


function convertTime(t)
    t = t/1000000 --converting microseconds to seconds by dividing by a million (1 microsecond = 1/1,000,000th of 1 second)

    local hours = math.floor(t/3600)

    local rawMinutes = ((t/3600)*60)
    
    if rawMinutes>60  then 
        minutes = math.floor(rawMinutes-60)
    else minutes = math.floor(rawMinutes)
    end
    
    local seconds = math.floor((rawMinutes - math.floor(rawMinutes))*60)

    return string.format("%02d:%02d:%02d",hours,minutes,seconds)
end
