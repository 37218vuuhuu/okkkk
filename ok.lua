local http = require("socket.http")
local json = require("cjson")

-- Replace the URL with the actual API endpoint
local apiEndpoint = "https://vak-sms.com/api/getNumber/?apiKey=5173b48b286b40fd8b4a3c9182516570&service=tg&country=id"

-- Function to make a GET request
function makeGetRequest(url)
    local response, statusCode, headers, statusLine = http.request(url)

    if statusCode == 200 then
        return response
    else
        print("Error: " .. statusLine)
        return nil
    end
end

-- Make the GET request
local jsonResponse = makeGetRequest(apiEndpoint)

-- Check if the request was successful
if jsonResponse then
    -- Parse the JSON response
    local data = json.decode(jsonResponse)

    -- Accessing specific fields in the JSON data
    local tel = data.tel
    local idNum = data.idNum

    -- Print or use the retrieved data
    print("Telephone number: " .. tostring(tel))
    print("ID Number: " .. idNum)
else
    print("Failed to retrieve data.")
end
