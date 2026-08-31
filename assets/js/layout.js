// Shared Layout Component Injector
// Dynamically builds header and sidebar navigation elements on page load

(function() {
    document.addEventListener('DOMContentLoaded', () => {
        injectSidebarAndHeader();
    });

    function injectSidebarAndHeader() {
        const profile = window.Auth.getUserProfile();
        if (!profile) return; // Not logged in

        const currentPath = window.location.pathname;
        const pageName = currentPath.substring(currentPath.lastIndexOf('/') + 1) || 'dashboard.html';

        // 1. Inject App Sidebar
        const sidebar = document.querySelector('.app-sidebar');
        if (sidebar) {
            // Get user initials
            const initials = profile.name 
                ? profile.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase()
                : 'U';

            // Define all sidebar items with their required roles
            const allNavItems = [
                { href: 'dashboard.html', text: 'Dashboard', roles: ['all'] },
                { href: 'events.html', text: 'Events', roles: ['super_admin', 'prog_admin', 'academic_lead', 'coordinator', 'management', 'project_director', 'ceo'] },
                { href: 'students.html', text: 'Participants', roles: ['super_admin', 'prog_admin', 'centre_incharge', 'coordinator', 'project_director', 'ceo'] },
                { href: 'centres.html', text: 'Centres', roles: ['super_admin', 'prog_admin', 'coordinator', 'management', 'project_director', 'ceo'] },
                { href: 'users.html', text: 'Users', roles: ['super_admin', 'prog_admin'] },
                { href: 'judge-dashboard.html', text: 'Judge Panel', roles: ['judge', 'final_judge', 'super_admin', 'prog_admin', 'project_director', 'ceo'] },
                { href: 'results.html', text: 'Results & Rankings', roles: ['all'] },
                { href: 'evidence.html', text: 'Evidence Upload', roles: ['super_admin', 'prog_admin', 'centre_incharge', 'project_director', 'ceo'] },
                { href: 'reports.html', text: 'Reports', roles: ['super_admin', 'prog_admin', 'management', 'project_director', 'ceo'] }
            ];

            // Filter nav items based on user roles
            const userRoles = profile.roles || [];
            const visibleNavItems = allNavItems.filter(item => {
                if (item.roles.includes('all')) return true;
                return userRoles.some(r => item.roles.includes(r));
            });

            // Generate Nav Links HTML
            const navLinksHtml = visibleNavItems.map(item => {
                const isActive = pageName.startsWith(item.href.split('.')[0]) ? 'active' : '';
                return `
                    <a href="${item.href}" class="nav-link ${isActive}">
                        <span>${item.text}</span>
                    </a>
                `;
            }).join('');

            // Sidebar Inner HTML
            sidebar.innerHTML = `
                <div class="sidebar-logo">
                    <div class="logo-icon">LI</div>
                    <div class="logo-text">Literacy India</div>
                </div>
                
                <nav class="sidebar-nav">
                    ${navLinksHtml}
                </nav>
                
                <div class="sidebar-footer">
                    <div class="user-badge">
                        <div class="user-avatar" id="avatarInitials">${initials}</div>
                        <div class="user-details">
                            <span class="user-name user-name-display">${escapeHTML(profile.name)}</span>
                            <span class="user-role user-role-display">${escapeHTML(formatRoles(profile.roles))}</span>
                        </div>
                    </div>
                    <button class="logout-btn" id="logoutBtn">Logout</button>
                </div>
            `;

            // Bind logout button handler
            const logoutBtn = sidebar.querySelector('#logoutBtn');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', () => {
                    window.Auth.signOut();
                });
            }
        }

        // 2. Inject App Header
        const header = document.querySelector('.app-header');
        if (header) {
            // Keep existing title element (like h1 or p)
            const titleEl = header.querySelector('.header-title h1') || header.querySelector('h1') || document.createElement('h1');
            const pageTitle = titleEl.textContent || 'Literacy India Portal';

            const centreText = profile.centres ? profile.centres.centre_name : 'All Centres (HQ)';
            const formattedRoles = formatRoles(profile.roles);

            header.innerHTML = `
                <div class="menu-toggle" id="menuToggle" style="display: none;">
                    <span style="font-size: 1.5rem;">☰</span>
                </div>
                
                <div class="header-title">
                    <h1 id="headerTitleText">${escapeHTML(pageTitle)}</h1>
                    <p class="user-centre-display">${escapeHTML(centreText)}</p>
                </div>
                
                <div class="header-actions">
                    <span class="badge badge-active user-role-display">${escapeHTML(formattedRoles)}</span>
                </div>
            `;

            // Re-bind menu toggle responsive event drawer
            const menuToggle = header.querySelector('#menuToggle');
            const appSidebar = document.querySelector('.app-sidebar');
            if (menuToggle && appSidebar) {
                menuToggle.addEventListener('click', (e) => {
                    e.stopPropagation();
                    appSidebar.classList.toggle('open');
                });
            }

            // Close sidebar when clicking main body
            const main = document.querySelector('.app-main');
            if (main && appSidebar) {
                main.addEventListener('click', () => {
                    appSidebar.classList.remove('open');
                });
            }
        }

        // Apply UI Rules from permissions if available
        if (window.Permissions && typeof window.Permissions.applyUIRules === 'function') {
            window.Permissions.applyUIRules();
        }
    }

    function formatRoles(roles) {
        if (!roles || roles.length === 0) return 'User';
        return roles.map(r => r.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase())).join(', ');
    }

    function escapeHTML(str) {
        if (!str) return '';
        return String(str).replace(/[&<>'"]/g, 
            tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
        );
    }
})();
