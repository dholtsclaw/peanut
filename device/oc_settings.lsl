/*------------------------------------------------------------------------------

 Settings, Build 110

 Wendy's OpenCollar Distribution
 https://github.com/wendystarfall/opencollar

--------------------------------------------------------------------------------

 OpenCollar v1.000 - v3.600 (OpenCollar - submission set free):

 Copyright © 2008, 2009, 2010 Cleo Collins, Garvin Twine, Joy Stipe,
 Master Starship, Nandana Singh, Satomi Ahn, et al.

 The project in its original form concluded on October 19, 2011. Everything past
 this date is a derivative of OpenCollar's original SVN trunk from Google Code.

--------------------------------------------------------------------------------

 OpenCollar v3.700 - v3.720 (nirea's ocupdater):

 Copyright © 2011 Alex Carpenter, nirea, Satomi Ahn, xx Reyes

 https://github.com/OpenCollarUpdates/ocupdater/commits/release

--------------------------------------------------------------------------------

 OpenCollar v3.750 - v3.809 (Satomi's OpenCollarUpdates):

 Copyright © 2012 Satomi Ahn, Xenhat Liamano

 https://github.com/OpenCollarUpdates/ocupdater/commits/3.8
 https://github.com/OpenCollarUpdates/ocupdater/commits/beta

--------------------------------------------------------------------------------

 OpenCollar v3.809 - v3.843 (Joy's OpenCollar Evolution):

 Copyright © 2013 Joy Stipe

 https://github.com/JoyStipe/ocupdater/commits/Project_Evolution

--------------------------------------------------------------------------------

 OpenCollar v3.844 - v3.998 (Wendy's OpenCollar API 3.9):

 Copyright © 2013 Medea Destiny, Rebbie, Wendy Starfall
 Copyright © 2014 littlemousy, Romka Swallowtail, Wendy Starfall

 https://github.com/OpenCollar/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 Virtual Disgrace Collar v1.0.0 - v2.1.1 (virtualdisgrace.com):

 Copyright © 2011, 2012, 2013 Wendy Starfall
 Copyright © 2014 littlemousy, Wendy Starfall

 https://github.com/WendyStarfall/opencollar/commits/master
 https://github.com/VirtualDisgrace/opencollar/commits/master

--------------------------------------------------------------------------------

 OpenCollar v4.0.0 - v6.7.5 - Peanut build 9 (virtualdisgrace.com):

 Copyright © 2015, 2016, 2017, 2018 Garvin Twine, Wendy Starfall

 https://github.com/VirtualDisgrace/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, see www.gnu.org/licenses/gpl-2.0

------------------------------------------------------------------------------*/

integer g_iBuild = 110;

string g_sCard = ".settings";
string g_sSplitLine;
integer g_iLineNr;
key g_kLineID;
key g_kCardID;
list g_lExceptionTokens = ["texture","glow","shininess","color","intern"];
key g_kLoadFromWeb;
key g_kURLLoadRequest;
key g_kWearer;

integer CMD_OWNER = 500;

integer NOTIFY=1002;

integer LM_SETTING_SAVE = 2000;
integer LM_SETTING_REQUEST = 2001;
integer LM_SETTING_RESPONSE = 2002;
integer LM_SETTING_DELETE = 2003;
integer LM_SETTING_EMPTY = 2004;

integer DIALOG = -9000;
integer DIALOG_RESPONSE = -9001;
integer LINK_DIALOG = 3;
integer LINK_UPDATE = -10;
integer REBOOT = -1000;
integer LOADPIN = -1904;
integer BUILD_REQUEST = 17760501;

integer g_iRebootConfirmed;
key g_kConfirmDialogID;
string g_sSampleURL = "https://goo.gl/adCn8Y";

list g_lSettings;

integer g_iSayLimit = 1024;
integer g_iCardLimit = 255;
string g_sDelimiter = "\\";

string SplitToken(string sIn, integer iSlot) {
    integer i = llSubStringIndex(sIn, "_");
    if (!iSlot) return llGetSubString(sIn, 0, i - 1);
    return llGetSubString(sIn, i + 1, -1);
}

integer GroupIndex(list lCache, string sToken) {
    string sGroup = SplitToken(sToken, 0);
    integer i = llGetListLength(lCache) - 1;
    for (; ~i ; i -= 2) {
        if (SplitToken(llList2String(lCache, i - 1), 0) == sGroup) return i + 1;
    }
    return -1;
}
integer SettingExists(string sToken) {
    if (~llListFindList(g_lSettings, [sToken])) return TRUE;
    return FALSE;
}

list SetSetting(list lCache, string sToken, string sValue) {
    integer idx = llListFindList(lCache, [sToken]);
    if (~idx) return llListReplaceList(lCache, [sValue], idx + 1, idx + 1);
    idx = GroupIndex(lCache, sToken);
    if (~idx) return llListInsertList(lCache, [sToken, sValue], idx);
    return lCache + [sToken, sValue];
}

string GetSetting(string sToken) {
    integer i = llListFindList(g_lSettings, [sToken]);
    return llList2String(g_lSettings, i + 1);
}

DelSetting(string sToken) {
    integer i = llGetListLength(g_lSettings) - 1;
    if (SplitToken(sToken, 1) == "all") {
        sToken = SplitToken(sToken, 0);
        for (; ~i; i -= 2) {
            if (SplitToken(llList2String(g_lSettings, i - 1), 0) == sToken)
                g_lSettings = llDeleteSubList(g_lSettings, i - 1, i);
        }
        return;
    }
    i = llListFindList(g_lSettings, [sToken]);
    if (~i) g_lSettings = llDeleteSubList(g_lSettings, i, i + 1);
}

list Add2OutList(list lIn, string sDebug) {
    if (!llGetListLength(lIn)) return [];
    list lOut;
    string sBuffer;
    string sTemp;
    string sID;
    string sPre;
    string sGroup;
    string sToken;
    string sValue;
    integer i;
    for (i=0 ; i < llGetListLength(lIn); i += 2) {
        sToken = llList2String(lIn, i);
        sValue = llList2String(lIn, i + 1);
        sGroup = llToUpper(SplitToken(sToken, 0));
        if (sDebug == "print" && ~llListFindList(g_lExceptionTokens,[llToLower(sGroup)])) jump next;
        sToken = SplitToken(sToken, 1);
        integer bIsSplit = FALSE ;
        integer iAddedLength = llStringLength(sBuffer) + llStringLength(sValue)
            + llStringLength(sID) +2;
        if (sGroup != sID || llStringLength(sBuffer) == 0 || iAddedLength >= g_iCardLimit ) {
            if ( llStringLength(sBuffer) ) lOut += [sBuffer] ;
            sID = sGroup;
            sPre = "\n" + sID + "=";
        }
        else sPre = sBuffer + "~";
        sTemp = sPre + sToken + "~" + sValue;
        while (llStringLength(sTemp)) {
            sBuffer = sTemp;
            if (llStringLength(sTemp) > g_iCardLimit) {
                bIsSplit = TRUE ;
                sBuffer = llGetSubString(sTemp, 0, g_iCardLimit - 2) + g_sDelimiter;
                sTemp = "\n" + llDeleteSubString(sTemp, 0, g_iCardLimit - 2);
            } else sTemp = "";
            if ( bIsSplit ) {
                lOut += [sBuffer];
                sBuffer = "" ;
            }
        }
        @next;
    }
    if ( llStringLength(sBuffer) ) lOut += [sBuffer] ;
    return lOut;
}

PrintSettings(key kID, string sDebug) {
    list lOut;
    list lSay = ["/me Settings:\n"];
    if (sDebug == "debug")
        lSay = ["/me Settings Debug:\n"];
    lSay += Add2OutList(g_lSettings, sDebug);
    string sOld;
    string sNew;
    integer i;
    while (llGetListLength(lSay)) {
        sNew = llList2String(lSay, 0);
        i = llStringLength(sOld + sNew) + 2;
        if (i > g_iSayLimit) {
            lOut += [sOld];
            sOld = "";
        }
        sOld += sNew;
        lSay = llDeleteSubList(lSay, 0, 0);
    }
    lOut += [sOld];
    while (llGetListLength(lOut)) {
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+llList2String(lOut, 0), kID);
        lOut = llDeleteSubList(lOut, 0, 0);
    }
}

LoadSetting(string sData, integer iLine) {
    string sID;
    string sToken;
    string sValue;
    integer i;
    if (iLine == 0 && g_sSplitLine != "" ) {
        sData = g_sSplitLine ;
        g_sSplitLine = "" ;
    }
    if (iLine) {
        sData = llStringTrim(sData, STRING_TRIM_HEAD);
        if (sData == "" || llGetSubString(sData, 0, 0) == "#") return;
        if (llStringLength(g_sSplitLine)) {
            sData = g_sSplitLine + sData ;
            g_sSplitLine = "" ;
        }
        if (llGetSubString(sData,-1,-1) == g_sDelimiter) {
            g_sSplitLine = llDeleteSubString(sData,-1,-1) ;
            return;
        }
        i = llSubStringIndex(sData, "=");
        sID = llGetSubString(sData, 0, i - 1);
        sData = llGetSubString(sData, i + 1, -1);
        if (~llSubStringIndex(llToLower(sID), "_")) return;
        else if (~llListFindList(g_lExceptionTokens,[sID])) return;
        sID = llToLower(sID)+"_";
        list lData = llParseString2List(sData, ["~"], []);
        for (i = 0; i < llGetListLength(lData); i += 2) {
            sToken = llList2String(lData, i);
            sValue = llList2String(lData, i + 1);
            if (sValue != "") {
                if (sID == "auth_") {
                    sToken = llToLower(sToken);
                    if (~llListFindList(["block","trust","owner"],[sToken])) {
                        list lTest = llParseString2List(sValue,[","],[]);
                        list lOut;
                        integer n;
                        do {
                            if (llList2Key(lTest,n))
                                lOut += llList2String(lTest,n);
                        } while (++n < llGetListLength(lTest));
                        sValue = llDumpList2String(lOut,",");
                        lTest = [];
                        lOut = [];
                    }
                }
                if (sValue) g_lSettings = SetSetting(g_lSettings, sID + sToken, sValue);
            }
        }
    }
}

SendValues() {
    integer n;
    string sToken;
    list lOut;
    for (; n < llGetListLength(g_lSettings); n += 2) {
        sToken = llList2String(g_lSettings, n) + "=";
        sToken += llList2String(g_lSettings, n + 1);
        if (llListFindList(lOut, [sToken]) == -1) lOut += [sToken];
    }
    n = 0;
    for (; n < llGetListLength(lOut); n++)
        llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, llList2String(lOut, n), "");
    llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, "settings=sent", "");
}

UserCommand(integer iAuth, string sStr, key kID) {
    string sStrLower = llToLower(sStr);
    if (sStrLower == "print settings" || sStrLower == "debug settings") PrintSettings(kID, llGetSubString(sStrLower,0,4));
    else if (!llSubStringIndex(sStrLower,"load")) {
        if (iAuth == CMD_OWNER) {
            if (llSubStringIndex(sStrLower,"load url") == 0 && iAuth == CMD_OWNER) {
                string sURL = llList2String(llParseString2List(sStr,[" "],[]),2);
                if (!llSubStringIndex(sURL,"http")) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Fetching settings from "+sURL,kID);
                    g_kURLLoadRequest = kID;
                    g_kLoadFromWeb = llHTTPRequest(sURL,[HTTP_METHOD, "GET"],"");
                } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Please enter a valid URL like: "+g_sSampleURL,kID);
            } else if (sStrLower == "load card" || sStrLower == "load") {
                if (llGetInventoryKey(g_sCard)) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+ "\n\nLoading backup from "+g_sCard+" card. If you want to load settings from the web, please type: /%CHANNEL% %PREFIX% load url <url>\n\nwww.opencollar.at/settings\n",kID);
                    g_kLineID = llGetNotecardLine(g_sCard, g_iLineNr);
                } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"No "+g_sCard+" to load found.",kID);
            }
        } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
    } else if (sStrLower == "reboot" || sStrLower == "reboot --f") {
        if (g_iRebootConfirmed || sStrLower == "reboot --f") {
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Rebooting your %DEVICETYPE% ....",kID);
            g_iRebootConfirmed = FALSE;
            llMessageLinked(LINK_ALL_OTHERS, REBOOT,"reboot","");
            llSetTimerEvent(2.0);
        } else {
            g_kConfirmDialogID = llGenerateKey();
            llMessageLinked(LINK_DIALOG,DIALOG,(string)kID+"|\nAre you sure you want to reboot the %DEVICETYPE%?|0|Yes`No|Cancel|"+(string)iAuth,g_kConfirmDialogID);
        }
    } else if (sStrLower == "show storage") {
        llSetPrimitiveParams([PRIM_TEXTURE,ALL_SIDES,TEXTURE_BLANK,<1,1,0>,ZERO_VECTOR,0.0,PRIM_FULLBRIGHT,ALL_SIDES,TRUE]);
        llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"\n\nTo hide the storage prim again type:\n\n/%CHANNEL% %PREFIX% hide storage\n",kID);
    } else if (sStrLower == "hide storage")
        llSetPrimitiveParams([PRIM_TEXTURE,ALL_SIDES,TEXTURE_TRANSPARENT,<1,1,0>,ZERO_VECTOR,0.0,PRIM_FULLBRIGHT,ALL_SIDES,FALSE]);
    else if (sStrLower == "runaway") llSetTimerEvent(2.0);
}

default {
    state_entry() {
        if (llGetStartParameter() == 825) llSetRemoteScriptAccessPin(0);
        if (llGetNumberOfPrims() > 5) g_lSettings = ["intern_dist",(string)llGetObjectDetails(llGetLinkKey(1),[27])];
        llSleep(0.5);
        g_kWearer = llGetOwner();
        g_iLineNr = 0;
        if (!llGetStartParameter()) {
            if (llGetInventoryKey(g_sCard)) {
                g_kLineID = llGetNotecardLine(g_sCard, g_iLineNr);
             g_kCardID = llGetInventoryKey(g_sCard);
            } else llSetTimerEvent(1);
        }
    }

    on_rez(integer iParam) {
        if (g_kWearer == llGetOwner())
            llSetTimerEvent(2.0);
        else llResetScript();
    }

    dataserver(key kID, string sData) {
        if (kID == g_kLineID) {
            if (sData != EOF) {
                LoadSetting(sData,++g_iLineNr);
                g_kLineID = llGetNotecardLine(g_sCard, g_iLineNr);
            } else {
                g_iLineNr = 0;
                LoadSetting(sData,g_iLineNr);
                llSetTimerEvent(1.0);
                SendValues();
            }
        }
    }

    http_response(key kID, integer iStatus, list lMeta, string sBody) {
        if (kID ==  g_kLoadFromWeb) {
            if (iStatus == 200) {
                if (lMeta)
                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Invalid URL. You need to provide a raw text file like this: "+g_sSampleURL,g_kURLLoadRequest);
                else {
                    list lLoadSettings = llParseString2List(sBody,["\n"],[]);
                    if (lLoadSettings) {
                        llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Settings fetched.",g_kURLLoadRequest);
                        integer i;
                        string sSetting;
                        do {
                            sSetting = llList2String(lLoadSettings,0);
                            i = llGetListLength(lLoadSettings);
                            lLoadSettings = llDeleteSubList(lLoadSettings,0,0);
                            LoadSetting(sSetting,i);
                        } while (i);
                        SendValues();
                    } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Empty site provided to load settings.",g_kURLLoadRequest);
                }
            } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Invalid url provided to load settings.",g_kURLLoadRequest);
            g_kURLLoadRequest = "";
        }
    }

    link_message(integer iSender, integer iNum, string sStr, key kID) {
        if (iNum == CMD_OWNER || kID == g_kWearer) UserCommand(iNum, sStr, kID);
        else if (iNum == LM_SETTING_SAVE) {
            list lParams = llParseString2List(sStr, ["="], []);
            string sToken = llList2String(lParams, 0);
            string sValue = llList2String(lParams, 1);
            g_lSettings = SetSetting(g_lSettings, sToken, sValue);
        }
        else if (iNum == LM_SETTING_REQUEST) {
            if (SettingExists(sStr)) llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_RESPONSE, sStr + "=" + GetSetting(sStr), "");
            else if (sStr == "ALL") {
                llSetTimerEvent(2.0);
            } else llMessageLinked(LINK_ALL_OTHERS, LM_SETTING_EMPTY, sStr, "");
        }
        else if (iNum == LM_SETTING_DELETE) DelSetting(sStr);
        else if (iNum == DIALOG_RESPONSE && kID == g_kConfirmDialogID) {
            list lMenuParams = llParseString2List(sStr, ["|"], []);
            kID = llList2Key(lMenuParams,0);
            if (llList2String(lMenuParams,1) == "Yes") {
                g_iRebootConfirmed = TRUE;
                UserCommand(llList2Integer(lMenuParams,3),"reboot",kID);
            } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Reboot aborted.",kID);
        } else if (iNum == LOADPIN && ~llSubStringIndex(llGetScriptName(),sStr)) {
            integer iPin = (integer)llFrand(99999.0)+1;
            llSetRemoteScriptAccessPin(iPin);
            llMessageLinked(iSender, LOADPIN, (string)iPin+"@"+llGetScriptName(),llGetKey());
        } else if (iNum == LINK_UPDATE) {
            if (sStr == "LINK_DIALOG") LINK_DIALOG = iSender;
            else if (sStr == "LINK_REQUEST") llMessageLinked(LINK_ALL_OTHERS,LINK_UPDATE,"LINK_SAVE","");
        } else if (iNum == BUILD_REQUEST)
            llMessageLinked(iSender,iNum+g_iBuild,llGetScriptName(),"");
    }

    timer() {
        llSetTimerEvent(0.0);
        SendValues();
    }

    changed(integer iChange) {
        if (iChange & CHANGED_INVENTORY) {
            if (llGetInventoryKey(g_sCard) != g_kCardID) {
                g_iLineNr = 0;
                if (llGetInventoryKey(g_sCard)) {
                    g_kLineID = llGetNotecardLine(g_sCard, g_iLineNr);
                    g_kCardID = llGetInventoryKey(g_sCard);
                }
            } else {
                llSetTimerEvent(1.0);
                SendValues();
            }
        }
    }
}
