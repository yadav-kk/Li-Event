// Authentication Management Module

const Auth = {
    // Perform User Sign In
    async signIn(email, password) {
        if (!window.supabaseClient) throw new Error("Supabase client is not initialized.");
        
        const { data, error } = await window.supabaseClient.auth.signInWithPassword({
            email,
            password
        });
        
        if (error) throw error;
        
        // Fetch User Profile details
        await this.syncSessionProfile(data.user);
        return data;
    },

    // Perform User Sign Out
    async signOut() {
        if (!window.supabaseClient) return;
        await window.supabaseClient.auth.signOut();
        localStorage.removeItem('user_session');
        localStorage.removeItem('user_profile');
        window.location.href = '../pages/login.html';
    },

    // Fetch Profile and Roles for Logged User
    async syncSessionProfile(user) {
        if (!user) return null;
        
        // Query Profile
        const { data: profile, error: profileErr } = await window.supabaseClient
            .from('profiles')
            .select('*, centres(centre_name, centre_code)')
            .eq('id', user.id)
            .single();
            
        if (profileErr) {
            console.error("Error fetching profile:", profileErr);
            return null;
        }

        // Query Roles
        const { data: userRoles, error: rolesErr } = await window.supabaseClient
            .from('user_roles')
            .select('role_id')
            .eq('profile_id', user.id);

        if (rolesErr) {
            console.error("Error fetching user roles:", rolesErr);
            profile.roles = ['management']; // Fallback default
        } else {
            profile.roles = userRoles.map(ur => ur.role_id);
        }

        // Save session locally
        localStorage.setItem('user_session', JSON.stringify(user));
        localStorage.setItem('user_profile', JSON.stringify(profile));
        return profile;
    },

    // Retrieve cached Profile
    getUserProfile() {
        const cached = localStorage.getItem('user_profile');
        return cached ? JSON.parse(cached) : null;
    },

    // Retrieve cached Auth User
    getAuthUser() {
        const cached = localStorage.getItem('user_session');
        return cached ? JSON.parse(cached) : null;
    },

    // Check Role Authorization
    hasRole(rolesToCheck) {
        const profile = this.getUserProfile();
        if (!profile || !profile.roles) return false;
        
        const roles = Array.isArray(rolesToCheck) ? rolesToCheck : [rolesToCheck];
        return profile.roles.some(r => roles.includes(r));
    },

    // Secure Routes
    async checkSessionRedirect(allowedRoles = []) {
        if (!window.supabaseClient) return;
        
        // Verify current active session with Supabase
        const { data: { session } } = await window.supabaseClient.auth.getSession();
        
        if (!session) {
            localStorage.removeItem('user_session');
            localStorage.removeItem('user_profile');
            // Prevent redirect loops
            if (!window.location.pathname.endsWith('login.html')) {
                window.location.href = './login.html';
            }
            return false;
        }

        let profile = this.getUserProfile();
        if (!profile) {
            profile = await this.syncSessionProfile(session.user);
        }

        // If specific roles required, assert matching permissions
        if (allowedRoles.length > 0) {
            const hasAccess = this.hasRole(allowedRoles);
            if (!hasAccess) {
                alert("Unauthorized: You do not have permissions to access this page.");
                window.location.href = './dashboard.html';
                return false;
            }
        }
        
        return true;
    }
};

window.Auth = Auth;
