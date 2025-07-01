// esbuild.config.js via DeepseekV3
const { build } = require('esbuild');
const { sassPlugin } = require('esbuild-sass-plugin');

build({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  plugins: [
    sassPlugin({
      // Optional: add if using Bootstrap or other libs
      loadPaths: ['node_modules']
    })
  ],
  loader: {
    // Add other loaders if needed
    '.png': 'file',
    '.svg': 'file'
  }
}).catch(() => process.exit(1));
