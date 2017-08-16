#include <File.au3>
#include <Array.au3>

Func _DirRemoveContents($folder)
    Local $search, $file
    If StringRight($folder, 1) <> "\" Then $folder = $folder & "\"
    If NOT FileExists($folder) Then Return 0
    FileSetAttrib($folder & "*","-RSH")
    FileDelete($folder & "*.*")
    $search = FileFindFirstFile($folder & "*")
    If $search = -1 Then Return 0
    While 1
        $file = FileFindNextFile($search)
        If @error Then ExitLoop
        If StringRight($file, 1) = "." Then ContinueLoop
        DirRemove($folder & $file, 1)
    WEnd
    Return FileClose($search)
EndFunc


$inifilename = "minimizeproject.ini"

$inputfolder  				= IniRead(@ScriptDir & "\" & $inifilename, "General", "InputFolder", "error")
$outputfolder 				= IniRead(@ScriptDir & "\" & $inifilename, "General", "OutputFolder", "error")
$yuifullpath  				= IniRead(@ScriptDir & "\" & $inifilename, "General", "YuiFullPath", "error")
$htmlminimizerfullpath 		= IniRead(@ScriptDir & "\" & $inifilename, "General", "HtmlMinimizerFullPath", "error")



Local $yuiExtensions[2] = [".css", ".js"]
Local $htmlExtensions[2] = [".html", ".htm"]

Local $yuiExtensionsSize = UBound($yuiExtensions)
Local $fileSizeChart[4] = [0, 0, 0, 0]
Local $fileSize = 0
Local $arraySearchResult = 0

$inputfoldercontent = _FileListToArrayRec($inputfolder, "*", 1, 1)
$inputfolderfolders = _FileListToArrayRec($inputfolder, "*", 2, 1)

;~ _DirRemoveContents($outputfolder)
For $i = 1 To $inputfolderfolders[0] Step 1
   DirCreate($outputfolder & "/" & $inputfolderfolders[$i])
Next

Local $sDrive
Local $sDir
Local $sFileName
Local $sExtension

Func getFileSize($fileName)
   Local $fileSize2
   Local $tryCount = 0
   Do
	  $tryCount += 1
	  if ($tryCount>1) then
		 Sleep(100)
	  Endif
	  $fileSize2 = FileGetSize( $fileName )
	  ConsoleWrite($fileName & " " & $fileSize2 & " " & $tryCount & @CRLF)
   Until (($fileSize2 <> 0) OR ($tryCount > 100))
   return $fileSize2
EndFunc

;~ _ArrayDisplay($inputfoldercontent)
For $i = 1 To $inputfoldercontent[0] Step 1
   $fileinfo = _PathSplit($inputfoldercontent[$i], $sDrive, $sDir, $sFileName, $sExtension)
   ConsoleWrite($sExtension & @CRLF)
   $arraySearchResult = _ArraySearch($yuiExtensions, $sExtension)
   if ($arraySearchResult <> -1) Then
	  $runcmd = 'java -jar "' & $yuifullpath & '" "' & $inputfolder & "/" & $inputfoldercontent[$i] & '" -o "' & $outputfolder & "/" & $inputfoldercontent[$i] & '"'
	  ConsoleWrite($runcmd & @CRLF)
	  RunWait($runcmd)
;~ 	  $fileSize  = getFileSize($outputfolder & "/" & $inputfoldercontent[$i])
	  $fileSize = FileGetSize( $outputfolder & "/" & $inputfoldercontent[$i] )
	   ConsoleWrite($outputfolder & "/" & $inputfoldercontent[$i] & " " & $fileSize & @CRLF)
	  $fileSizeChart[$arraySearchResult] += $fileSize

   EndIf
   $arraySearchResult = _ArraySearch($htmlExtensions, $sExtension)
   if ($arraySearchResult <> -1) Then
	  $runcmd = 'node "' & $htmlminimizerfullpath & '" "' & $inputfolder & "/" & $inputfoldercontent[$i] & '" "' & $outputfolder & "/" & $inputfoldercontent[$i] & '"'
	  ConsoleWrite($runcmd & @CRLF)
	  RunWait($runcmd)
;~ 	  $fileSize  = getFileSize($outputfolder & "/" & $inputfoldercontent[$i])
	  $fileSize = FileGetSize( $outputfolder & "/" & $inputfoldercontent[$i] )
	  ConsoleWrite($outputfolder & "/" & $inputfoldercontent[$i] & " " & $fileSize & @CRLF)
	  $fileSizeChart[$arraySearchResult + $yuiExtensionsSize] += $fileSize

   EndIf


Next


Local $fileSizeChartYo[3] = ["", "", ""]
$fileSizeChartYo[0] = "css  : " & $fileSizeChart[0]
$fileSizeChartYo[1] = "js   : " & $fileSizeChart[1]

$fileSizeChart[2] += $fileSizeChart[3]

$fileSizeChartYo[2] = "html : " & $fileSizeChart[2]

_ArrayDisplay($fileSizeChartYo)


;~ Run($yuifullpath &

;~ _ArrayDisplay($inputfoldercontent)

;~ MsgBox(4096, "Title", $inputfoldercontent)

;~ MsgBox(4096, "Title", $inputfolder)
