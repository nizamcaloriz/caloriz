# Caloriz Netlify Pages

Static pages for Caloriz app - Privacy Policy and Account Deletion.

## Pages Included

- **index.html** - Landing page with links
- **privacy-policy.html** - Privacy policy for Play Store/App Store compliance
- **delete-account.html** - Instructions for account deletion

## Deployment to Netlify

### Option 1: Deploy via Netlify CLI
```bash
cd netlify
npm install -g netlify-cli
netlify deploy --prod
```

### Option 2: Deploy via Netlify Dashboard
1. Go to https://app.netlify.com
2. Click "Add new site" → "Deploy manually"
3. Drag and drop the `netlify` folder
4. Your site will be live!

### Option 3: Connect to Git
1. Push this repository to GitHub
2. Go to Netlify Dashboard
3. Click "Import from Git"
4. Select your repository
5. Set build directory to `netlify`
6. Deploy!

## Custom Domain
After deployment, you can add a custom domain:
- Go to Site settings → Domain management
- Add custom domain (e.g., caloriz.com)

## URLs
After deployment, your pages will be available at:
- `https://your-site.netlify.app/`
- `https://your-site.netlify.app/privacy-policy.html`
- `https://your-site.netlify.app/delete-account.html`

Short URLs also work:
- `https://your-site.netlify.app/privacy`
- `https://your-site.netlify.app/delete`

## Update Contact Information
Remember to update:
- Email address in privacy policy and delete account pages
- Company name if needed
- Add actual screenshots in delete account page
