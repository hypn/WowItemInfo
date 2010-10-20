#SingleInstance force

Menu, Tray, Tip, Hypn and Antivoid's WoWItemInfo 1.1

; Titan's "xpath" (AutoHotKey XML parser): http://www.autohotkey.net/~Titan/#xpath
#include xpath.ahk

; from this forum thread: http://www.autohotkey.com/forum/topic34972.html
Strip_HTML(html)
{
	Loop Parse, html, <>
		If (A_Index & 1)
		{
			y = %y%%A_LoopField%
		}
		StringReplace,y,y, /select,,All
		html=%y%
		return html
}

; hotkey
#w::
	
	title := "Hypn and Antivoid's WoWItemInfo 1.1"
	
	; backup the clipboard, copy the selected text to clipboard, assign it to a variable, then reset the clipboard
	ClipSaved := clipboard
	Send ^c
	ItemName := clipboard
	Clipboard := ClipSaved
	ClipSaved =  

	; download and parse the XML file
	UrlDownloadToFile, http://www.wowhead.com/?item=%ItemName%&xml, last_item.xml
	xpath_load(xmlfile, "last_item.xml")
	
	; get the "htmlTooltip" from the XML
	html_tooltip := xpath(xmlfile, "/wowhead/item/htmlTooltip/text()")

	; newline character, because I'm too lazy to work out how to do this properly
	NEWLINE := Chr(10)

	; tidy up html tool tip so we can display it in a messagebox
	StringReplace, html_tooltip, html_tooltip, &lt;!--, <--, All
	StringReplace, html_tooltip, html_tooltip, &quot;, , All
	StringReplace, html_tooltip, html_tooltip, &nbsp;, , All
	StringReplace, html_tooltip, html_tooltip, ]]>, , All
	StringReplace, html_tooltip, html_tooltip, <table width=, %NEWLINE%<table width=, All
	StringReplace, html_tooltip, html_tooltip, <br ></br>, %NEWLINE%, All
	StringReplace, html_tooltip, html_tooltip, </tr>, %NEWLINE%, All
	StringReplace, html_tooltip, html_tooltip, <th>, %A_SPACE%(, All
	StringReplace, html_tooltip, html_tooltip, </th>, ), All
	StringReplace, html_tooltip, html_tooltip, &#44;, `,, All

	; fix price
	StringReplace, html_tooltip, html_tooltip, moneysilver">, ">g , All
	StringReplace, html_tooltip, html_tooltip, moneycopper">, ">s , All
	StringReplace, html_tooltip, html_tooltip, " 0g", "", All
	
	; check if we were able to find the item
	StringLen, length, html_tooltip
	if (length > 0)
	{
		html_tooltip := Strip_HTML(html_tooltip)
		StringReplace, html_tooltip, html_tooltip, Price:, Price:%A_SPACE%, All
		MsgBox, 0, %title%, %html_tooltip%
	}
	else
	{
		MsgBox, 0, %title%, Item not found
	}

return