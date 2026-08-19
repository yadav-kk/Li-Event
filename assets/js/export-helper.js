// Export Helper Module for CSV & PDF Printing
const ExportHelper = {
    // Export a DOM table to CSV
    exportTableToCSV(tableId, filename = 'export.csv') {
        const table = document.getElementById(tableId);
        if (!table) {
            console.error("Table element not found:", tableId);
            return;
        }

        const rows = Array.from(table.querySelectorAll('tr'));
        const csvContent = rows.map(row => {
            const cols = Array.from(row.querySelectorAll('th, td'));
            return cols.map(col => {
                // Get cell text content
                let text = col.textContent || col.innerText || '';
                
                // Clean up trailing spaces and button/action texts
                text = text.trim();
                
                // Replace internal line breaks and multiple spaces
                text = text.replace(/\s+/g, ' ');
                
                // Escape quotes
                text = text.replace(/"/g, '""');
                return `"${text}"`;
            }).join(',');
        }).join('\n');

        this._downloadCSV(csvContent, filename);
    },

    _downloadCSV(content, filename) {
        const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.setAttribute('href', url);
        link.setAttribute('download', filename);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
};

window.ExportHelper = ExportHelper;
