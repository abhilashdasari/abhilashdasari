# Deployment Guide for Academic Portfolio

## GitHub Pages Deployment Instructions

1. **Repository Setup**
   - Go to your GitHub repository: https://github.com/abhilashdasari/abhilashdasari
   - Create a new branch named `gh-pages` if it doesn't exist

2. **File Structure**
   - Copy all the files from this project to your repository
   - Ensure the following structure:
     ```
     abhilashdasari/
     ├── static/
     │   ├── css/
     │   └── js/
     ├── templates/
     ├── index.html (move from templates/index.html)
     ├── CNAME (if you have a custom domain)
     └── README.md
     ```

3. **Required Changes**
   - Move the content from `templates/index.html` to the root `index.html`
   - Update all Flask-specific template syntax:
     - Replace `{{ url_for('static', filename='css/style.css') }}` with `static/css/style.css`
     - Replace `{{ url_for('static', filename='js/main.js') }}` with `static/js/main.js`
     - Remove Flask template inheritance (`{% extends %}` and `{% block %}` tags)
   - Update internal links to use direct paths instead of Flask routes

4. **GitHub Pages Setup**
   - Go to your repository settings
   - Navigate to "Pages" in the sidebar
   - Under "Source", select the `gh-pages` branch
   - Choose the root folder (/) as the publishing source
   - Click "Save"

5. **Custom Domain (Optional)**
   - If you want to use a custom domain:
     - Add a CNAME file with your domain
     - Update your domain's DNS settings
     - Configure the custom domain in GitHub Pages settings

6. **Verification**
   - Your site will be available at: https://abhilashdasari.github.io/abhilashdasari
   - Check that all links and resources load correctly
   - Verify that styles and JavaScript are working
   - Test on different devices and browsers

## Notes
- GitHub Pages only serves static content, so the Flask backend won't be available
- Blog functionality will need to be implemented differently for a static site
- Consider using a static site generator like Jekyll or Hugo for blog features
- Keep your repository public for GitHub Pages to work with free GitHub accounts

## Maintenance
- Regular updates can be pushed to the `gh-pages` branch
- GitHub Actions can be set up later for automated deployments
- Keep your dependencies and information up to date
