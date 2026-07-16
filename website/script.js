// =========================================================================
// Sho Ishida - Developer Portfolio Interactions (Dracula Blade Edition)
// =========================================================================

// Copy to Clipboard Utility for contact registry items
function setupCopyHandlers() {
  const contactLinks = document.querySelectorAll('.contact-link');
  
  contactLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      const href = link.getAttribute('href');
      let textToCopy = '';
      
      // If it's a mailto link, copy only the address, otherwise copy the link target URL
      if (href.startsWith('mailto:')) {
        e.preventDefault();
        textToCopy = href.replace('mailto:', '');
      } else {
        textToCopy = link.getAttribute('href');
      }
      
      navigator.clipboard.writeText(textToCopy).then(() => {
        const originalText = link.innerHTML;
        const label = link.querySelector('.label').textContent;
        
        // Show brief success feedback in the UI
        link.innerHTML = `<span class="label" style="color: var(--success);">${label}</span> Copied to clipboard!`;
        
        setTimeout(() => {
          link.innerHTML = originalText;
        }, 1800);
      }).catch(err => {
        console.error('Failed to copy text: ', err);
      });
    });
  });
}

// -------------------------------------------------------------------------
// Initialization
// -------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', () => {
  setupCopyHandlers();
});
