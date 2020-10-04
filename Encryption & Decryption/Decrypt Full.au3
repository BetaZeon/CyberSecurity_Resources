;Decrypt Hardcoded

#include <GUIConstantsEx.au3>
#include <Crypt.au3>

HotKeySet("{ESC}", "_Close")

Main()

;GUI for settings
Func Main()
   Local $hGUI = GUICreate("Decrypt", 400,270)
   GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")

   Local $lblEncryptedText = GUICtrlCreateLabel("Encrypted Text",30,20,280)
   Local $inputEncryptedText = GUICtrlCreateInput("",60,50,280)

   Local $lblSecKey = GUICtrlCreateLabel("Encryption Secret Key",30,80,280)
   Local $inputSecKey = GUICtrlCreateInput("SecureKey",60,110,280)

      Local $btnDecrypt = GUICtrlCreateButton("Decrypt", 140, 150, 120, 25)

   Local $lblDecryptedText = GUICtrlCreateLabel("Decrypted Text",30,190,280)
   Local $inputDecryptedText = GUICtrlCreateInput("",60,220,280)

   GUISetState(@SW_SHOW, $hGUI)

   While 1
	  $msg = GUIGetMsg()
	  Select
		 Case $msg == $btnDecrypt
			   Local $cryptSecKey = GUICtrlRead($inputSecKey)
			   Local $decrypted = _Decrypt($cryptSecKey, GUICtrlRead($inputEncryptedText))
			   GUICtrlSetData($inputDecryptedText, $decrypted)
		 Case $msg == $GUI_EVENT_CLOSE
			   _Close()
	  EndSelect
   WEnd
EndFunc

Func _Decrypt($sKey, $sData)
    Local $hKey = _Crypt_DeriveKey($sKey, $CALG_AES_256)
    Local $sDecrypted = BinaryToString(_Crypt_DecryptData(Binary($sData), $hKey, $CALG_USERKEY))
    _Crypt_DestroyKey($hKey)
    Return $sDecrypted
 EndFunc

 Func _Close()
  GUIDelete()
  Exit
EndFunc
