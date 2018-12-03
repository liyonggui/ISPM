import VueRouter from "vue-router";
import { isLogin } from "../config/login.js";

/**
 * root 级别的页面只有2个， index 和 login
 * 所有业务页面采用 ‘异步加载’ 的方式，减少手工 import 的麻烦
 * 添加路由要注意定义的前后顺序，有限匹配前面的规则
 */
import login from "../page/login.vue";
import index from "../page/index.vue";
import ready from "../page/ready.vue";
import register from "../page/system/user/register.vue";
import registerVerifyTel from "../page/system/user/registerVerifyTel.vue";
import children from "./routes.js";

const routes = [
  {
    path: "/login",
    component: login
  },
  {
    path: "/register",
    component: register
  },
  {
    path: "/registerVerifyTel",
    component: registerVerifyTel
  },
  {
    path: "/",
    component: ready,
    children: [
      {
        path: "/",
        redirect: "/index"
      },
      {
        path: "/index",
        component: index
      },
      ...children
    ]
  }
];

const router = new VueRouter({
  // 尝试使用history 模式
  // mode: 'history',
  scrollBehavior: () => ({ y: 0 }),
  routes
});

/**
 * 登录拦截，由于next 方法的拦截作用。不需要些else
 * next 有参数会阻断执行，没有参数会继续执行
 */
router.beforeEach((to, from, next) => {
  if (to.path === "/login") {
    if (isLogin()) {
      next("/");
    } else {
      next();
    }
  } else {
    if (
      isLogin() ||
      to.path === "/register" ||
      to.path === "/registerVerifyTel"
    ) {
      next();
    } else {
      next("/login");
    }
  }
});
router.afterEach(route => {
  if (route.path !== "/login") {
    sessionStorage.path = route.path;
  }
});

function getRoutes(resources) {
  let routes = {
    path: "/",
    component: index,
    children: [
      {
        path: "",
        redirect: "/index"
      }
    ]
  };
  if (resources && resources.length) {
    for (let i = 0; i < resources.length; i++) {
      let resource = resources[i];
      let category = {
        name: resource.name,
        path: resource.path
      };
      if (resource.redirect) {
        category.redirect = resource.redirect;
      }
      routes.children.push(category);
      if (resource.children && resource.children.length) {
        for (let j = 0; j < resource.children.length; j++) {
          let item = resource.children[j];
          routes.children.push({
            name: item.name,
            path: item.path,
            label: item.label,
            component: function(resolve) {
              require.ensure([], function() {
                resolve(require("../page/" + item.component + ".vue"));
              });
            }
          });
        }
      }
    }
  }
  // 最后添加404规则
  routes.children.push({
    path: "*",
    component: notFound
  });
  // 返回数组格式
  return [routes];
}

export { router, getRoutes };
