// Supabase Client Initialization

const SUPABASE_URL = "https://rvmrblyemavqcfivjfsm.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_8HaBBAECdqSKjfZzs-B8_A_Jex-eyvZ";

if (typeof supabase === 'undefined') {
    console.error(
        "Supabase library not loaded. Make sure to include the CDN script tag in your HTML file:\n" +
        "<script src=\"https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2\"></script>"
    );
}

// Global Supabase Client Instance
const supabaseClient = typeof supabase !== 'undefined' 
    ? supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    : null;

// Expose to window for global access across modules
window.supabaseClient = supabaseClient;
