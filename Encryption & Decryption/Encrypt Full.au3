;Encrypt hardcoded

#include <GUIConstantsEx.au3>
#include <Crypt.au3>

HotKeySet("{ESC}", "_Close")

Main()

;GUI for settings
Func Main()
   Local $hGUI = GUICreate("Encrypt", 400,270)
   GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")

   Local $lblUnencryptedText = GUICtrlCreateLabel("Unencrypted Text",30,20,280)
   Local $inputUnencryptedText = GUICtrlCreateInput("",60,50,280)

   Local $lblSecKey = GUICtrlCreateLabel("Encryption Secret Key",30,80,280)
   Local $inputSecKey = GUICtrlCreateInput("SecureKey",60,110,280)

   Local $btnEncrypt = GUICtrlCreateButton("Encrypt", 140, 150, 120, 25)

   Local $lblEncryptedText = GUICtrlCreateLabel("Encrypted Text",30,190,280)
   Local $inputEncryptedText = GUICtrlCreateInput("",60,220,280)

   GUISetState(@SW_SHOW, $hGUI)

   While 1
	  $msg = GUIGetMsg()
	  Select
		 Case $msg == $btnEncrypt
			   Local $cryptSecKey = GUICtrlRead($inputSecKey)
			   Local $passCrypt = _Encrypt($cryptSecKey, GUICtrlRead($inputUnencryptedText))
			   GUICtrlSetData($inputEncryptedText, $passCrypt)
		 Case $msg == $GUI_EVENT_CLOSE
			   _Close()
	  EndSelect
   WEnd
EndFunc

Func _Encrypt($sKey, $sData)
    Local $hKey = _Crypt_DeriveKey($sKey, $CALG_AES_256)
    Local $bEncrypted = _Crypt_EncryptData($sData, $hKey, $CALG_USERKEY)
    _Crypt_DestroyKey($hKey)
    Return $bEncrypted
 EndFunc

Func _Close()
  GUIDelete()
  Exit
EndFunc
