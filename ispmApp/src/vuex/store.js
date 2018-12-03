// 引入各模块的store

import userinfo from "./modules/userinfo.js";

export default {
  state: {
    token: "",
    offLine: false,
    logoutPath: "",
    sysDict: [],
    currentProject: {},
    projects: [],
    sysDict: [],
    userMenu: [],
    accountInfo: {
      name: "",
      phone: "",
      company: {
        name: ""
      },
      depart: ""
    },
    operationPermission: [],
  },
  getters: {
    getToken: state => {
      return state.token;
    }
  },
  mutations: {
    setToken(state, token) {
      state.token = token;
    },
    initializeDictionary(state, sysDict) {
      state.sysDict = sysDict;
    },
    initializeBizDictionary(state, bizDict) {
      state.bizDict = bizDict;
    },
    initializePermission(state, userMenu) {
      state.userMenu = userMenu;
    },
    initializeUserInfo(state, accountInfo) {
      state.accountInfo = accountInfo;
    },
    initializeOperationPermission(state, operationPermission) {
      state.operationPermission = operationPermission;
    },
    //缓存项目及项目备选项 LFLJ
    initializeCurrentProject(state, currentProject) {
      state.currentProject = currentProject;
    },
    initializeProjects(state, projects) {
      state.projects = projects;
    },
    setOffLineStatus(state, status){
      state.offLine = status;
      sessionStorage.offLine = status;
    }
  },
  actions: {
    setToken({ commit }, token) {
      commit("setToken", token);
    }
  },
  modules: {
    userinfo: userinfo
  }
};
