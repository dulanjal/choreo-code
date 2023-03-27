import ballerina/http;

type RiskRequest record {
    string ip;
};

type ipGeolocationResp record {
    string ip;
    string country_code2;
};

// API key from ipgeolocation.io
configurable string GEO_API_KEY = ?;
configurable string SAFE_COUNTRY_CODE = ?;

service / on new http:Listener(8090) {
    resource function post risk(@http:Payload RiskRequest req) returns http:Response|error? {

        string ip = req.ip;

        http:Client ipGeolocation = check new ("https://api.ipgeolocation.io");
        ipGeolocationResp geoResponse = check ipGeolocation->get(string `/ipgeo?apiKey=${GEO_API_KEY}&ip=${ip}&fields=country_code2`);

        http:Response response = new ;
        response.setJsonPayload({hasRisk: geoResponse.country_code2 != SAFE_COUNTRY_CODE});
        response.statusCode = 200;
        
        return response;
    }
}