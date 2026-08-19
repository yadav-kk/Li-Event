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

// Automatically sync event statuses based on current date & time
async function syncEventStatuses() {
    if (!window.supabaseClient) return;

    try {
        const { data: events, error } = await window.supabaseClient
            .from('events')
            .select('id, start_date, end_date, registration_start, registration_end, status')
            .in('status', ['PLANNING', 'REGISTRATION', 'PRACTICE', 'ASSESSMENT']);

        if (error) throw error;
        if (!events || events.length === 0) return;

        const now = new Date();
        const updates = [];

        for (const e of events) {
            if (!e.registration_start || !e.registration_end || !e.start_date || !e.end_date) continue;
            
            const regStart = new Date(`${e.registration_start}T05:00:00+05:30`);
            const regEnd = new Date(`${e.registration_end}T23:59:00+05:30`);
            const start = new Date(`${e.start_date}T05:00:00+05:30`);
            const end = new Date(`${e.end_date}T23:59:00+05:30`);

            let targetStatus = e.status;

            if (now < regStart) {
                targetStatus = 'PLANNING';
            } else if (now >= regStart && now <= regEnd) {
                targetStatus = 'REGISTRATION';
            } else if (now > regEnd && now < start) {
                targetStatus = 'PRACTICE';
            } else if (now >= start && now <= end) {
                targetStatus = 'ASSESSMENT';
            } else if (now > end) {
                targetStatus = 'COMPLETED';
            }

            if (targetStatus !== e.status) {
                updates.push(
                    window.supabaseClient
                        .from('events')
                        .update({ status: targetStatus })
                        .eq('id', e.id)
                );
            }
        }

        if (updates.length > 0) {
            await Promise.all(updates);
        }
    } catch (err) {
        console.error("Error syncing event statuses:", err);
    }
}

window.syncEventStatuses = syncEventStatuses;

