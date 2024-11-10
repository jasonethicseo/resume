const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  transpileDependencies: [
    'bootstrap-vue'
  ],
  devServer: {
    proxy: {
      "/api": {	
        target: "http://internal-ecs-alb-back-970728-1880887050.ca-central-1.elb.amazonaws.com",
        changeOrigin: true,
        // pathRewrite: { '^/api': '' },
      }
    }
  },
  lintOnSave: false
});
