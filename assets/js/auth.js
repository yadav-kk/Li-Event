// Authentication Management Module (Direct Custom Database Auth)

const Auth = {
    // Perform User Sign In
    async signIn(email, password) {
        if (!window.supabaseClient) throw new Error("Supabase client is not initialized.");
        
        // Query users table directly
        const { data: users, error } = await window.supabaseClient
            .from('users')
            .select('*')
            .eq('email', email)
            .eq('password', password);
            
        if (error) throw error;
        
        if (!users || users.length === 0) {
            throw new Error("Invalid email or password.");
        }
        
        const user = users[0];
        
        // Fetch roles from user_roles
        const { data: roles, error: rolesErr } = await window.supabaseClient
            .from('user_roles')
            .select('role_id')
            .eq('user_id', user.id);
            
        if (rolesErr) {
            console.error("Error fetching user roles:", rolesErr);
            user.roles = ['management'];
        } else {
            user.roles = roles.map(r => r.role_id);
        }
        
        // Fetch centre details if present
        if (user.centre_id) {
            const { data: centre } = await window.supabaseClient
                .from('centres')
                .select('centre_name, centre_code')
                .eq('id', user.centre_id)
                .single();
            user.centres = centre;
        }

        // Save session locally
        localStorage.setItem('user_session', JSON.stringify(user));
        localStorage.setItem('user_profile', JSON.stringify(user));
        return user;
    },

    // Perform User Sign Out
    async signOut() {
        localStorage.removeItem('user_session');
        localStorage.removeItem('user_profile');
        window.location.href = '../pages/login.html';
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

    // Refresh User Profile from DB
    async refreshProfile() {
        const cached = this.getUserProfile();
        if (!cached || !cached.id || !window.supabaseClient) return cached;
        try {
            const { data: user } = await window.supabaseClient
                .from('users')
                .select('*')
                .eq('id', cached.id)
                .single();
            if (user) {
                const { data: roles } = await window.supabaseClient
                    .from('user_roles')
                    .select('role_id')
                    .eq('user_id', user.id);
                user.roles = roles ? roles.map(r => r.role_id) : (cached.roles || ['management']);
                if (user.centre_id) {
                    const { data: centre } = await window.supabaseClient
                        .from('centres')
                        .select('centre_name, centre_code')
                        .eq('id', user.centre_id)
                        .single();
                    user.centres = centre;
                } else {
                    user.centres = null;
                }
                localStorage.setItem('user_session', JSON.stringify(user));
                localStorage.setItem('user_profile', JSON.stringify(user));
                return user;
            }
        } catch (e) {
            console.warn("Could not refresh profile:", e);
        }
        return cached;
    },

    // Secure Routes
    async checkSessionRedirect(allowedRoles = []) {
        let profile = this.getUserProfile();
        
        if (!profile) {
            localStorage.removeItem('user_session');
            localStorage.removeItem('user_profile');
            // Prevent redirect loops
            if (!window.location.pathname.endsWith('login.html')) {
                window.location.href = './login.html';
            }
            return false;
        }

        // Keep profile in sync with DB
        profile = await this.refreshProfile();

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
