// UI Permission Helper Module

const Permissions = {
    // Hide/show elements on the page based on the current user's roles
    applyUIRules() {
        const profile = window.Auth.getUserProfile();
        if (!profile || !profile.roles) {
            // Unauthenticated: hide everything marked with roles
            document.querySelectorAll('[data-allowed-roles]').forEach(el => {
                el.style.display = 'none';
            });
            return;
        }

        // Apply rules on elements declaring required roles
        const elements = document.querySelectorAll('[data-allowed-roles]');
        elements.forEach(el => {
            const rolesList = el.getAttribute('data-allowed-roles');
            if (rolesList === 'all') return; // visible to any logged in user
            
            const allowed = rolesList.split(',').map(r => r.trim());
            const hasAccess = profile.roles.some(r => allowed.includes(r));
            
            if (!hasAccess) {
                // If it is a container, hide it; if it is an inline element, hide or remove
                el.style.setProperty('display', 'none', 'important');
            }
        });

        // Set user text across layout (sidebar, profile badges, etc.)
        const nameBadges = document.querySelectorAll('.user-name-display');
        nameBadges.forEach(el => el.textContent = profile.name);

        const roleBadges = document.querySelectorAll('.user-role-display');
        roleBadges.forEach(el => {
            // Capitalize role word
            const formattedRoles = profile.roles.map(r => r.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase()));
            el.textContent = formattedRoles.join(', ');
        });
        
        const centreBadges = document.querySelectorAll('.user-centre-display');
        centreBadges.forEach(el => {
            if (profile.centres) {
                el.textContent = profile.centres.centre_name;
            } else {
                el.textContent = 'All Centres (HQ)';
            }
        });
    }
};

window.Permissions = Permissions;

// Automatically bind to DOMContentLoaded to secure layouts on load
document.addEventListener('DOMContentLoaded', () => {
    Permissions.applyUIRules();
});
