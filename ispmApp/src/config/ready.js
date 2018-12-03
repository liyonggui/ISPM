/**
 * 系统准备数据
 */
// import Axios from "axios";
// import { resourceFormat } from "src/utils/dataFormat";
import { listenPlusReady } from "./plusReady";

function init(vue, callback) {
  console.log("init.......");
  vue.$axios.post("/initData", {type: 'app'}).then(resp => {
    // TODO 字典进行按需引用
    initializeDictionary(vue, resp.sysDict);
    initializeBizDictionary(vue, resp.bizDict);
    initializePermission(vue, resp.userMenu);
    initializeOperationPermission(vue,resp.userMenu);
    // //缓存项目及项目备选项 LFLJ
    initializeCurrentProject(vue, resp.currentProject);
    initializeProjects(vue, resp.projects);
    initializeUserInfo(vue, resp.userInfo);
  });
  callback && callback();
}

function initializeDictionary(vue, dict) {
  vue.$store.commit("initializeDictionary", dict);
}
function initializeBizDictionary(vue, dict) {
  vue.$store.commit("initializeBizDictionary", dict);
}
function initializeOperationPermission(vue, userMenu) {
  let menu = Object.assign({},menu,userMenu)
  let pemission=[]
  collectionPermission(menu, pemission)
  vue.$store.commit("initializeOperationPermission", pemission);
}
function collectionPermission(userMenu, pemission) {
  if (userMenu.children && userMenu.children.length > 0) {
      userMenu.children.forEach((item) => {
          if (item.isShow == 'sys_menu_type_0') {
              pemission.push(item)
          }
        collectionPermission(item, pemission)
      });
  }
}

function initializeCurrentProject(vue, currentProject) {
  vue.$store.commit("initializeCurrentProject", currentProject);
}

function initializeProjects(vue, projects) {
  vue.$store.commit("initializeProjects", projects);
}

function initializeUserInfo(vue, accountInfo) {
  vue.$store.commit("initializeUserInfo", accountInfo);
}

function initializePermission(vue, userMenu) {
  vue.$store.commit("initializePermission", userMenu);
}
// 设置当前用户
// function setUserInfo(vue) {
//   return vue.$store.dispatch("setUserInfo", vue);
// }

// // 设置组织信息
// function setOrgInfo(vue) {
//   var clientId = vue.$store.getters.getUserInfo.clientId;
//   return vue.$store.dispatch("setOrgInfo", { vue, clientId });
// }

// // 配置菜单资源
// function setResource(vue) {
//   return vue.$store.dispatch("setResource", vue);
// }

// function configResource(vue) {
//   let resources = vue.$store.getters.getResource;
//   let operations = resourceFormat(resources);
//   vue.$store.commit("setOperation", operations);
// }

// function setAllUsers(vue) {
//   return vue.$store.dispatch("setUsers", vue);
// }

// function mergeDict(vue) {
//   let users = vue.$store.getters.getUsers;
//   vue.$store.commit("setDicts", { users: users });
// }

// function setCurrentProjectId(vue) {
//   let userProfile = vue.$store.getters.getUserProfile;
//   if (userProfile && userProfile.details && userProfile.details.length) {
//     let results = userProfile.details.filter(item => {
//       return item.key === "projectId";
//     });
//     if (results[0] && results[0].data) {
//       let projectId = JSON.parse(results[0].data).projectId;
//       vue.$store.commit("setCurrentProjectId", projectId);
//       // console.log('set projectId end.' + projectId);
//     }
//   } else {
//     let projects = vue.$store.getters.projects;
//     if (projects && projects.length) {
//       let projectId = projects[0].id;
//       let projectIdMode = {
//         vue: vue,
//         key: "projectId",
//         data: JSON.stringify({ projectId: projectId })
//       };
//       vue.$store.dispatch("saveProfileByKey", projectIdMode);
//       vue.$store.commit("setCurrentProjectId", projectId);
//     }
//   }
// }

export { init, listenPlusReady };
