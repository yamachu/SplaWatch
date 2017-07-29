using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using JsAPI = System.Func<object, System.Threading.Tasks.Task<object>>;
using SwitchOnlineClient.Network.NintendoAccount;
using SwitchOnlineClient.Network.GameWebService;
using SwitchOnlineClient.Network.SwitchOnlineAccount;
using SwitchOnlineClient.Models;

namespace IkaLib
{
    class Program
    {
        static void Main() {}

        public async Task<object> Invoke(object obj)
        {
            return new
            {
                generateOAuth = (JsAPI)(async (_) => {
                    return NintendoOAuthService.GenerateOAuthLoginURL();
                }),
                generateToken = (JsAPI)(async (tokens) => {
                    var tokenPair = (IDictionary<string, object>)tokens;
                    var session_token_code = tokenPair["session_token_code"] as string;
                    var session_token_code_verifier = tokenPair["session_token_code_verifier"] as string;

                    var token = await NintendoOAuthService.GetSessionToken(session_token_code.Trim(), session_token_code_verifier.Trim());

                    return token.SessionToken;
                }),
                generateIksm = (JsAPI)(async (_sessionToken) => {
                    var sessionToken = await NintendoOAuthService.GetTokens(_sessionToken as string);

                    var accountToken = await SwitchAccountService.GetAccountToken(sessionToken);
                    var gameServices = await SwitchAccountService.GetGameService();

                    var spl2 = gameServices.GameServiceList.First(g => g.Name == "スプラトゥーン2");

                    var gameServiceToken = await SwitchAccountService.GetGameWebServiceToken(spl2.ID);

                    var client = new WebServiceClient(spl2.URI, gameServiceToken.Body.AccessToken);
                    await client.Initialize();

                    return client.GetCookieSession("iksm_session");
                })
            };
        }
    }
}
