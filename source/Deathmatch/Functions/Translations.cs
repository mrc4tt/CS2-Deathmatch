using CounterStrikeSharp.API;
using CounterStrikeSharp.API.Core;
using CounterStrikeSharp.API.Core.Translations;

namespace Deathmatch
{
    public partial class Deathmatch
    {
        private static bool IsTranslatablePlayer(CCSPlayerController? player)
        {
            return player != null && player.IsValid && !player.IsBot && !player.IsHLTV;
        }

        // Text in the player's own language (css_lang). Console, bots and HLTV get the server language.
        public string Tr(CCSPlayerController? player, string key, params object[] args)
        {
            if (!IsTranslatablePlayer(player))
                return Localizer[key, args];
            return Localizer.ForPlayer(player!, key, args);
        }

        // Chat line with the plugin prefix, in the player's language.
        public string TrChat(CCSPlayerController? player, string key, params object[] args)
        {
            return $"{Tr(player, "Chat.Prefix")} {Tr(player, key, args)}";
        }

        // Cache key for per-language caching of HUD text; "" means server language.
        private static string LanguageKey(CCSPlayerController? player)
        {
            return IsTranslatablePlayer(player) ? player!.GetLanguage().Name : "";
        }

        // Per-language cached translation for text sent to many players at once.
        private string TrCached(Dictionary<string, string> cache, CCSPlayerController player, string key, params object[] args)
        {
            string lang = LanguageKey(player);
            if (!cache.TryGetValue(lang, out var text))
            {
                text = Tr(player, key, args);
                cache[lang] = text;
            }
            return text;
        }

        // Chat message to every human player, each in their own language.
        private void PrintToChatAllTranslated(string key, params object[] args)
        {
            var cache = new Dictionary<string, string>();
            foreach (var p in Utilities.GetPlayers())
            {
                if (!IsTranslatablePlayer(p))
                    continue;

                string lang = LanguageKey(p);
                if (!cache.TryGetValue(lang, out var text))
                {
                    text = TrChat(p, key, args);
                    cache[lang] = text;
                }
                p.PrintToChat(text);
            }
        }
    }
}
