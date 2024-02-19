socket = require("socket")
json = require "json"
ltn12 = require("ltn12")
https = require('ssl.https') 
http = require("socket.http") 
mime = require("mime")

function sleep(x)
	usleep(x*1000);
end

function readFile(path)
    local file = io.open(path,"r");
    if file then
        local _list = {};
        for l in file:lines() do
            table.insert(_list,l)
        end
        file:close();
        return _list
    end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function GET(Link)
	local url = Link
	local resp = {}
	local body, code, headers = https.request{ 
        url = url, 
        sink = ltn12.sink.table(resp) 
    }
	if code ~= 200 then 
		toast("Error: "..(code or ''),5)
		return false
	else return resp[1]
	end
end

function GETS(Link)
	local url = Link
	local resp = {}
	local body, code, headers = http.request{ 
        url = url, 
        sink = ltn12.sink.table(resp) 
    }
	if code ~= 200 then 
		toast("Error: "..(code or ''),5)
		return false
	else return resp[1]
	end
end

function Autoproxy()
    key = readFile(rootDir().."/Telegram/key.txt")
    local response = GET("https://proxy.shoplike.vn/Api/getNewProxy?access_token="..key[1])
    if response ~= nil and response ~= false and string.find(response, "status") ~= nil then
        if response ~= nil and string.find(response , "error")~= nil  and string.find(response , "het han") ~= nil then
            local data = json.decode(response)
            alert(data.mess,1)
            return false
        end
        if response ~= nil and string.find(response , "error")~= nil  and string.find(response , "proxy moi") ~= nil then
            local data = json.decode(response)
            for i=1,data.nextChange do
                toast(string.format("Delay %d change proxy",i),1)
                sleep(1000)
            end 
            Autoproxy()
            return true
        end
        if response ~= nil and string.find(response , "success") ~= nil then
            local data = json.decode(response)
            proxy = data.data.proxy
            copyText("http://"..mime.b64(proxy)) 
            openURL("shadowrocket://route/proxy")
            sleep(1000)
            while true do
                if appState("com.liguangming.Shadowrocket") == "ACTIVATED" then
                    openURL("shadowrocket://connect")
                    sleep(1000)
                    appKill("com.liguangming.Shadowrocket")
                    return true
                end
            end  
            return true
        end      
    else
        sleep(10000)
        Autoproxy()
        return true
    end
    return false
end

function changedata()
    io.popen('uiopen XoaInfo://Reset')
    sleep(2000);
    local looptimexoainfo = 45
    repeat
      looptimexoainfo = looptimexoainfo - 1
      local flag = appState("com.ienthach.XoaInfo");
      toast("XoaInfo Reset Data "..looptimexoainfo)
      sleep(2000);
      if looptimexoainfo <= 1 then
        looptimexoainfo = 45
        io.popen('uiopen XoaInfo://Reset')
      end
    until flag == "NOT RUNNING"
    return true
end

function getIP()
    local resp = {}
	local body, code, headers = http.request{ 
        url = "http://ip-api.com/json/", 
        headers = {
            ["content-type"] = "application/json",
        },
        sink = ltn12.sink.table(resp) 
    }
	if code ~= 200 then 
		return false
    else
        toast(table.concat(resp))
        return true
	end
end

function waitImage2(imagePath, timeoutSeconds)
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < timeoutSeconds do
        local result = findImage(imagePath, 0, 0.95, nil, false)
        if result and next(result) then
            for i, v in pairs(result) do
                tap(math.floor(v[1]), math.floor(v[2]))
				sleep(300)
				tap(math.floor(v[1]), math.floor(v[2]))
            end
            sleep(1000)
            return true
        end
        sleep(1000)
        elapsedTime = os.time() - startTime
        toast("dang chay "..elapsedTime,1)
    end
    return false
end

function waitImage1(imagePath, timeoutSeconds)
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < timeoutSeconds do
        local result = findImage(imagePath, 0, 0.95, nil, false)
        if result and next(result) then
            for i, v in pairs(result) do
                --tap(math.floor(v[1]), math.floor(v[2]))
                touchDown(4, math.floor(v[1]), math.floor(v[2]));
                usleep(1500000);
                touchUp(4, math.floor(v[1]), math.floor(v[2]));
            end
            sleep(1000)
            return true
        end
        sleep(1000)
        elapsedTime = os.time() - startTime
        toast("dang chay "..elapsedTime,1)
    end
    return false
end

function waitImage(imagePath, timeoutSeconds)
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < timeoutSeconds do
        local result = findImage(imagePath, 0, 0.95, nil, false)
        if result and next(result) then
            for i, v in pairs(result) do
                tap(math.floor(v[1]), math.floor(v[2]))
            end
            sleep(1000)
            return true
        end
        sleep(1000)
        elapsedTime = os.time() - startTime
        toast("dang chay "..elapsedTime,1)
    end
    return false
end

function checkImg(imagePath, timeoutSeconds)
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < timeoutSeconds do
        local result = findImage(imagePath, 0, 0.95, nil, false)
        if result and next(result) then
            for i, v in pairs(result) do
                return true
            end
        end
        sleep(1000)
        elapsedTime = os.time() - startTime
        toast("dang chay "..elapsedTime,1)
    end
    return false
end

function locationIMG(imagePath)
    local result = findImage(imagePath, 0, 0.95, nil, false)
    for i, v in pairs(result) do
        return math.floor(v[1]),math.floor(v[2])
    end
end

function firefox()
    --print("lấy số firefox")
    keyfirefox = readFile(rootDir().."/Telegram/keyfirefox.txt")
    local response = GET("https://vak-sms.com/api/getNumber/?apiKey=5173b48b286b40fd8b4a3c9182516570&service=tg&country=id")
    --print(tostring(response))
    if response then
        local iter = string.gmatch(response, "([^|]+)")
        local dataArray = {}
        for element in iter do
            table.insert(dataArray, element)
        end
        if dataArray[1] == "1" then
            idorder = dataArray[2]
            numberid = dataArray[7]
            return true
        end
    end
    return false
end

function getOTP1()
    local startTime = os.time()
    local elapsedTime = 0
    goodAU = false
    vuaotpAU = false
    hcotpAU = false
    while elapsedTime < 120 do
        if firefox() then
            firefoxAU = true
            return true
        end
        elapsedTime = os.time() - startTime
        toast("Đợi lấy số "..elapsedTime,1)
    end
    return false
end

function firefoxOTP(idorder,timeoutSeconds)
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < timeoutSeconds do
        if checkImg(rootDir() .. "/Telegram/dataclick/code.PNG",2) == false then
            return false
        end
        keyfirefox = readFile(rootDir().."/Telegram/keyfirefox.txt")
        local response = GET("https://vak-sms.com/api/getSmsCode/?apiKey=" .. keyfirefox[1] .. "&idNum="..idorder)
        --print(tostring(response))
        if response then
            local iter = string.gmatch(response, "([^|]+)")
            local dataArray = {}
            for element in iter do
                table.insert(dataArray, element)
            end
            if dataArray[1] == "1" then
                OTP = dataArray[2]
                inputText(OTP)
                return OTP
            end
        end
        sleep(2000)
        elapsedTime = os.time() - startTime
        toast("đang lấy otp của Vaksms "..elapsedTime,1)
    end
    phanhoi(idorder)
    --print("OTP không về")
    return false
end

function HTTPSpost(link,data)
	local http = require"socket.http"
    local ltn12 = require"ltn12"
    local reqbody = data
    local respbody = {} 
    local result, respcode, respheaders, respstatus = http.request {
        method = "POST",
        url = link,
        source = ltn12.source.string(reqbody),
        headers = {
            ["content-type"] = "application/x-www-form-urlencoded",
            ["content-length"] = tostring(#reqbody)
        },
        sink = ltn12.sink.table(respbody)
    }
    respbody = table.concat(respbody)
end


function check_nb()
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < 30 do
        calling = 1
        if checkImg(rootDir() .. "/Telegram/dataclick/checkproxy.PNG",1) or checkImg(rootDir() .. "/Telegram/dataclick/again.PNG",1) then
            phanhoi(idorder)
            --print("lỗi proxy hoặc late")
            return false
        end
        if checkImg(rootDir() .. "/Telegram/dataclick/code.PNG",1) then
            return true
        end 
        if checkImg(rootDir() .. "/Telegram/dataclick/band.PNG",1) or checkImg(rootDir() .. "/Telegram/dataclick/again.PNG",1) then 
            if waitImage(rootDir() .. "/Telegram/dataclick/ok.PNG",1) == false then 
                return false
            end
            xDT ,yDT = locationIMG(rootDir() .. "/Telegram/dataclick/detele.PNG",30) 
            for i = 1,9,1 do
                tap(xDT,yDT)
                usleep(1000)
            end
            calling = calling + 1
            if calling == 4 then return false end
            if getOTP1() then 
                if numberid ~= nil and numberid ~= false then
                sleep(1000)    
                inputText(numberid)
                else
                    return false
                end
                
            else
                return false
            end
            if waitImage2(rootDir() .. "/Telegram/dataclick/2.PNG",10) == false then 
                    return false
            end
            return check_nb()
        end
        sleep(1000)
        elapsedTime = os.time() - startTime
        toast("dang chay "..elapsedTime,1)
    end
    return false
end

function post2fa()
    if OTP == nil then
        OTP = 0
    end
    da = "entry.588448080=" .. "84" .. numberid .. "|" .. idorder..","..OTP..""
    urls11 = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSdghm1kUn5hRI4XzOmbMTa9CYckyYVcL1Z8ux0gkE1MtQubXw/formResponse"
    HTTPSpost(urls11,da)
    toast("da post 2fa",1)
end

function postVangApp()
    key = readFile(rootDir().."/Telegram/key.txt")
    da = "entry.150193993=" .. "84" .. numberid .."|".. key[9]..""
    urls11 = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSeo4ktGjSPbIZCaDnAK7jT5wCcw_JtRxkTl9cOSOPx0gH2Psw/formResponse"
    HTTPSpost(urls11,da)
    toast("da post văng app",1)
end

function check_2fa()
    if checkImg(rootDir() .. "/Telegram/dataclick/die2fa.PNG",5) then 
        post2fa()  
        return true
    end
    return false
end

function name()
	local fullFirstName = readFile(rootDir() .. "/Telegram/firstnameVN.txt")
	local fullLastName = readFile(rootDir() .. "/Telegram/lastnameVN.txt")
	local firtName = fullFirstName[math.random(1,tablelength(fullFirstName))];
	local lastName = fullLastName[math.random(1,tablelength(fullLastName))];
    sleep(1000)
    inputText(firtName)
    sleep(500)
    tap(350,560)
    sleep(500)
    inputText(lastName)
    sleep(500)
    tap(350,700)
end

function KeoLen(from,to,timesleepRandom)
	math.randomseed(os.time());
	local fingerID = math.random(1,9);
	local timesleep = timesleepRandom--50000
	touchDown(fingerID, math.random(199,204), 1045);
	usleep(timesleep);
	touchMove(fingerID, math.random(199,204), 625);
	usleep(timesleep);
	touchUp(fingerID, math.random(199,204), 625);
	usleep(timesleep);
	touchUp(fingerID, math.random(199,204), 625);
	sleep(2000);
end

function KeoXun(from,to,timesleepRandom)
	math.randomseed(os.time());
	local fingerID = math.random(1,9);
	local timesleep = timesleepRandom--50000
	touchDown(fingerID,from[1],from[2]);
	usleep(timesleep);
	touchMove(fingerID,to[1],to[2]);
	usleep(timesleep);
	touchUp(fingerID,from[1],from[2]);
	usleep(timesleep);
	touchUp(fingerID,to[1],to[2]);
	usleep(2000000);
end

function backup_post()
    local startTime = os.time()
    local elapsedTime = 0
    while elapsedTime < 15 do
        key = readFile(rootDir().."/Telegram/key.txt")
        automic_state = io.open("/private/var/mobile/Containers/Shared/AppGroup/" .. key[2] .. "/telegram-data/accounts-metadata/atomic-state")
        if automic_state then 
            data_backup = automic_state:read("*all")
            if data_backup ~= nil and string.find(data_backup, "backupData") ~= nil then
                datas = string.match(data_backup, "data(.-),")
                data = string.sub(datas, string.find(datas, "") + 3, string.find(datas, "]") - 4)
                log("84" .. numberid .. "|" .. data .. "&=")
                body = "entry.966737283=" .. "84" .. numberid .. "|" .. data .. "&="
                urls = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSdySMBKFk6KNQ0hao8KvAJwBut8ukfDgT9t0PHru-MbGTtVYw/formResponse"
                HTTPSpost(urls,body)
                toast("da post len gg sheet",2)
                return true
            end
        end
        sleep(1000)
        elapsedTime = os.time() - startTime
        toast("k tim thay data telegram",2)
    end
    postVangApp()
    --print("văng app mẹ nó rồi")
    return false
end

function vuotlen()
	local w=400;
    local y = 1100;
    local gap = 20;
    touchDown(0, 400, y);
    while y > w do
        y = y - gap;
        usleep(100);
        touchMove(0, 400, y);
    end
    touchUp(0, 400, y);
end

function dongapp()
    io.popen("activator send switch-off.com.a3tweaks.switch.vpn")
    sleep(500)
    keyPress(KEY_TYPE.HOME_BUTTON);
    keyPress(KEY_TYPE.HOME_BUTTON);
    sleep(1000)
    vuotlen()
    sleep(700)
    vuotlen()
    sleep(700)
    vuotlen()
    sleep(1000)
end

function bat2fa()
    if waitImage(rootDir() .. "/Telegram/dataclick/chats.PNG",5) == false 
    then
        appRun("ph.telegra.Telegraph")
        sleep(3000)
    end
   
    sleep(500)
    KeoLen(500,100,50000)

    --sleep(700)
    if waitImage(rootDir() .. "/Telegram/dataclick/privacy.PNG",5) == false 
        then 
            if waitImage(rootDir() .. "/Telegram/dataclick/chats.PNG",5) == false then return false end
            sleep(500)
            KeoLen(500,100,50000)
            if waitImage(rootDir() .. "/Telegram/dataclick/privacy.PNG",5) == false 
            then 
                if waitImage(rootDir() .. "/Telegram/dataclick/chats.PNG",5) == false then return false end
                sleep(500)
                KeoLen(500,100,50000)
                if waitImage(rootDir() .. "/Telegram/dataclick/privacy.PNG",5) == false 
                    then
                        toast("đợi 5 giây",1)
                        sleep(5000)
                        if waitImage(rootDir() .. "/Telegram/dataclick/chats.PNG",5) == false then end
                        sleep(500)
                        KeoLen(500,100,50000)
                        if waitImage(rootDir() .. "/Telegram/dataclick/privacy.PNG",5) == false then return false end
                    end
            end
        end

    --sleep(500)
    if waitImage(rootDir() .. "/Telegram/dataclick/tow2fa.PNG",10) == false then return false end

    if waitImage(rootDir() .. "/Telegram/dataclick/setpassword.PNG",5) == false
       then
            if waitImage(rootDir() .. "/Telegram/dataclick/back.PNG",5) == false then return false end
            if waitImage(rootDir() .. "/Telegram/dataclick/tow2fa.PNG",5) == false then return false end
            if waitImage(rootDir() .. "/Telegram/dataclick/setpassword.PNG",5) == false 
            then 
                if waitImage(rootDir() .. "/Telegram/dataclick/back.PNG",5) == false then return false end
                if waitImage(rootDir() .. "/Telegram/dataclick/tow2fa.PNG",5) == false then return false end
                if waitImage(rootDir() .. "/Telegram/dataclick/setpassword.PNG",5) == false 
                    then
                        toast("đợi 10 giây",10)
                        sleep(10000)
                        if waitImage(rootDir() .. "/Telegram/dataclick/back.PNG",5) == false then return false end
                        if waitImage(rootDir() .. "/Telegram/dataclick/tow2fa.PNG",5) == false then return false end
                        if waitImage(rootDir() .. "/Telegram/dataclick/setpassword.PNG",5) == false then return false end
                    end
            end
      end    
    --sleep(200)
    usleep(50000)
    inputText(key[8])
    usleep(50000)
    tap(math.random(585, 700), math.random(1260, 1300))
    usleep(50000)
    inputText(key[8])
    usleep(50000)
    tap(math.random(585, 700), math.random(1260, 1300))

    if waitImage(rootDir() .. "/Telegram/dataclick/skipsetting.PNG",30) == false then return end
    if waitImage(rootDir() .. "/Telegram/dataclick/xong.PNG",30) == false then return end
    if waitImage(rootDir() .. "/Telegram/dataclick/skipEm.PNG",10) == false then return end
    if waitImage(rootDir() .. "/Telegram/dataclick/skip.PNG",10) == false then return end
    if waitImage(rootDir() .. "/Telegram/dataclick/return.PNG",10) == false 
        then 
            if waitImage(rootDir() .. "/Telegram/dataclick/ok_tele.PNG",10) == false then return end
            if waitImage(rootDir() .. "/Telegram/dataclick/skipEm.PNG",10) == false then return end
            if waitImage(rootDir() .. "/Telegram/dataclick/skip.PNG",10) == false then return end  
            if waitImage(rootDir() .. "/Telegram/dataclick/return.PNG",10) == false then return end      
        end
    sleep(500)
end



function teleauto()
    key = readFile(rootDir().."/Telegram/key.txt")
    appRun("ph.telegra.Telegraph")
    sleep(2000)
    if appState("ph.telegra.Telegraph") == "NOT RUNNING" then
       return teleauto() end

    toast("Chon bat dau")
    sleep(1000)
    if waitImage(rootDir() .. "/Telegram/dataclick/1.PNG",3) == false then return false end       
    sleep(1000)
    if checkImg(rootDir() .. "/Telegram/dataclick/yourphone.PNG",3) == false then
        return false
    end
    toast("Nhap so dien thoai")
    if getOTP1() then 
        if numberid ~= nil and numberid ~= false then
            inputText(numberid)
        else
            return false
        end
    else
        return false
    end

    toast("Chon tiep tuc")
    if waitImage2(rootDir() .. "/Telegram/dataclick/2.PNG",10) == false then return false end

    toast("Dang checking")
    if check_nb() == false then 
        return false 
    end
    
    if checkImg(rootDir() .. "/Telegram/dataclick/call.PNG",2) or checkImg(rootDir() .. "/Telegram/dataclick/app.PNG",2) then
        return false
    end 
    if firefoxAU then
        if firefoxOTP(idorder,80) == false then
            keyfirefox = readFile(rootDir().."/Telegram/keyfirefox.txt") 
            local otpout = GET("http://www.firefox.fun/yhapi.ashx?act=apiReturn&token=" .. keyfirefox[1] .. "&pkey="..idorder.."&remark=-2")
            return false 
        end
    end
    if checkImg(rootDir() .. "/Telegram/dataclick/info.PNG",15) then 
        name()
        sleep(1000)
        if goodAU then
            Goodpost(numberid,"success")
        end
        if backup_post() == false then
            return false
        end
    else
        if check_2fa() then 
            if goodAU then
                Goodpost(numberid,"2fa")
            end
            --log("dinh 2fa")
            return false 
        end
        if backup_post() == false then
            return false
        end
        if goodAU then
            Goodpost(numberid,"2fa")
        end
    end
    sleep(1000)
    if checkImg(rootDir() .. "/Telegram/dataclick/chat.PNG",20) then
        return bat2fa()
    else
        bat2fa()
    end
end
function reg()
    if Autoproxy() == false then 
        --print("change proxy loi roi")
        return reg() 
    end
    toast("Change proxy susses",1)
    sleep(3000)
    if getIP() == false then 
        --print("change proxy loi roi")
        toast("khong co network")
        return false
    end
    if teleauto() == false then
        --print("reg loi r") 
        return false
    end
--print("suscess")
end

while true do
    changedata()
    toast("Change data susses",1)
    sleep(1000)
    io.popen("activator send switch-off.com.a3tweaks.switch.vpn")
    sleep(1000)
    appRun("com.liguangming.Shadowrocket")
    sleep(700)
    keyPress(KEY_TYPE.HOME_BUTTON);
    sleep(700)
    reg()
end