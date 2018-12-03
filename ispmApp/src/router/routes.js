/**
 * label: 用于在面包屑导航中显示
 */

const routes = [];

routes.push({
    label: "用户注册",
    path: "/register",
    component: getComponent("system/user/register")
});

routes.push({
    label: "短信注册",
    path: "/registerVerifyTel",
    component: getComponent("system/user/registerVerifyTel")
});

routes.push({
    label: "修改密码",
    path: "/system/changePassword",
    component: getComponent("system/user/changePassword")
});

//系统信息
routes.push({
    label: "系统信息",
    path: "/system/systemInfo",
    component: getComponent("system/systemInfo")
});
//项目详情
routes.push({
    label: "项目详情",
    path: "/project/detail",
    name: "projectDetail",
    component: getComponent("project/detail")
});
//离线队列
routes.push({
    label: "离线队列",
    path: "/system/offlineQueue",
    name: "sys_offlineQueue",
    component: getComponent("system/offlineQueue/offlineQueue")
});

//安全巡查
routes.push({
    label: "安全巡查记录",
    path: "/safe/safeInspection",
    name: "safe_safeInspection",
    component: getComponent("safe/safeInspection/safeInspection")
});
//安全巡查记录
routes.push({
    label: "安全巡查记录",
    path: "/safe/safeInspection/detail",
    name: "safe_safeInspection_detail",
    component: getComponent("safe/safeInspection/detail")
});
//安全巡查整改派单
routes.push({
    label: "安全巡查整改派单",
    path: "/safe/safeInspection/renovate",
    name: "safe_safeInspection_renovate",
    component: getComponent("safe/safeInspection/renovate")
});

/**安全交底 */
routes.push({
    label: "安全交底记录",
    path: "/safe/disclosure/list",
    name: "safe_disclosure_info",
    component: getComponent("safe/safeDisclosure/list")
});

/**安全交底 */
routes.push({
    label: "安全交底新建",
    path: "/safe/disclosure/create",
    name: "safe_disclosure_create",
    component: getComponent("safe/safeDisclosure/create")
});

/**安全交底 */
routes.push({
    label: "安全交底详细",
    path: "/safe/disclosure/detail",
    name: "safe_disclosure_detail",
    component: getComponent("safe/safeDisclosure/detail")
})


/**安全交底模板 */
routes.push({
    label: "安全交底模板",
    path: "/safe/disclosure/content",
    name: "safe_disclosure_content",
    component: getComponent("safe/safeDisclosureContent/list")
})

routes.push({
    label: "安全交底模板审批",
    path: "/safe/safeDisclosureContent/approve",
    name: "/safe/safe-disclosure/content/approve",
    component: getComponent("safe/safeDisclosureContent/approve")
})



/**安全交底模板新建 */
routes.push({
    label: "安全交底新建",
    path: "/safe/disclosure/content/create",
    name: "safe_disclosure_content_create",
    component: getComponent("safe/safeDisclosureContent/create")
})
/**安全交底模板详情 */
routes.push({
    label: "安全交底详情",
    path: "/safe/disclosure/content/detail",
    name: "safe_disclosure_content_detail",
    component: getComponent("safe/safeDisclosureContent/detail")
})

/**安全交底确认 */
routes.push({
    label: "安全交底确认",
    path: "/safe/disclosure-confirm/list",
    name: "safe_disclosure_confirm",
    component: getComponent("safe/safeDisclosureConfirm/list")
})

/**任务待办列表 */
routes.push({
    label: "待办任务",
    path: "/task/todo/list",
    name: "task_todo",
    component: getComponent("task/todo/list")
}),

routes.push({
    label: "丢了，找不着了",
    path: "/null",
    component: getComponent("404")
});
//设计图点位标注
routes.push({
  label: "设计图点位标注",
  path: "cad",
  component: getComponent("svg/views/main")
});
//危险点安全监控
routes.push({
    label: "危险点安全监控",
    path: "/safe/dangerPoint",
    name:"dangerPoint",
    component: getComponent("safe/safeDrawingPoint/monitor")
  });
//危险点列表
routes.push({
    label: "危险点列表",
    path: "/safe/safeDrawingPoint/list",
    name:"safe_drawing_point",
    component: getComponent("safe/safeDrawingPoint/list")
  });
//危险点电子围栏列表
routes.push({
    label: "危险点电子围栏列表",
    path: "/safe/electricFenceList/list",
    name:"electric_fence_list",
    component: getComponent("safe/electricFenceList/list")
  });

//危大工程安全监控
routes.push({
    label: "危大工程安全监控",
    path: "/danger/dangerProject",
    name:"dangerProject",
    component: getComponent("safe/safeDrawingProject/monitor")
  });
//危大工程列表
routes.push({
    label: "危大工程列表",
    path: "danger_project_list",
    name:"danger_project_list",
    component: getComponent("safe/safeDrawingProject/list")
  });
//危大工程电子围栏列表
routes.push({
    label: "危大工程电子围栏列表",
    path: "danger_rail_list",
    name:"danger_rail_list",
    component: getComponent("safe/projectElectricFenceList/list")
  });
  //危险点销项
  routes.push({
    label: "危险点销项",
    path: "/safe/safeDrawingPoint/renovate",
    name:"/safe/safeDrawingPoint/renovate",
    component: getComponent("safe/safeDrawingPoint/renovate")
  });
  //危大工程销项
routes.push({
    label: "危大工程销项",
    path: "/safe/safeDrawingProject/renovate",
    name:"/safe/safeDrawingProject/renovate",
    component: getComponent("safe/safeDrawingProject/renovate")
  });
  //危险点审批
routes.push({
    label: "危险点审批",
    path: "/safe/safeDrawingPoint/detail",
    name:"/safe/safeDrawingPoint/detail",
    component: getComponent("safe/safeDrawingPoint/detail")
  });
  //危大工程审批
routes.push({
    label: "危大工程审批",
    path: "/safe/safeDrawingProject/detail",
    name:"/safe/safeDrawingProject/detail",
    component: getComponent("safe/safeDrawingProject/detail")
  });
  //危险点电子围栏审批
routes.push({
    label: "危险点电子围栏审批",
    path: "/safe/electricFenceList/detail",
    name:"/safe/electricFenceList/detail",
    component: getComponent("safe/electricFenceList/detail")
  });
 //危大工程电子围栏审批
routes.push({
    label: "危大工程电子围栏审批",
    path: "/safe/projectElectricFenceList/detail",
    name:"/safe/projectElectricFenceList/detail",
    component: getComponent("safe/projectElectricFenceList/detail")
  });
//整改列表
routes.push({
    label: "整改列表",
    path: "safe/safeRectify",
    name:"safe_rectify_list",
    component: getComponent("safe/safeRectify/safeRectify")
});
//整改明细
routes.push({
    label: "整改明细",
    path: "safe/safeRectify/detail",
    name:"safe_rectify_detail",
    component: getComponent("safe/safeRectify/detail")
});
//整改详情
routes.push({
    label: "整改详情",
    path: "safe/safeRectify/info",
    name:"safe_rectify_info",
    component: getComponent("safe/safeRectify/info")
});
//整改结果
routes.push({
    label: "整改结果",
    path: "safe/safeRectify/result/approve",
    name:"/safe/safeRectify/result/approve",
    component: getComponent("safe/safeRectify/result/approve")
});
//整改结果复查
routes.push({
    label: "整改结果复查",
    path: "safe/safeRectify/resultReview/approve",
    name:"/safe/safeRectify/resultReview/approve",
    component: getComponent("safe/safeRectify/resultReview/approve")
});
//安全检查列表
routes.push({
    label: "安全检查列表",
    path: "safe/safeCheck/list",
    name:"safe_check",
    component: getComponent("safe/safeCheck/list")
  });
//安全检查详细
routes.push({
    label: "安全检查详细",
    path: "safe/safeCheck/detail",
    name:"safe_check_detail",
    component: getComponent("safe/safeCheck/detail")
  });
  //安全检查发起整改
routes.push({
    label: "安全检查发起整改",
    path: "safe/safeCheck/renovate",
    name:"safe_check_renovate",
    component: getComponent("safe/safeCheck/renovate")
  });
// 动态表单列表 - 仅展示
routes.push({
    label: "动态表单列表(仅展示)",
    path: "formdesigner/just-display-list",
    name:"fdjustdisplaylist",
    component: getComponent("formdesigner/just-display-list")
});
// 动态表单详情 - 仅展示
routes.push({
    label: "动态表单详情(仅展示)",
    path: "formdesigner/just-display-detail",
    name:"fdjustdisplaydetail",
    component: getComponent("formdesigner/just-display-detail")
});

function getComponent(path) {
    return function (resolve) {
        require.ensure([], function () {
            resolve(require("../page/" + path + ".vue"));
        });
    };
}

routes.map(function (item) {
    item.title = item.label;
    let path = item.path;
    if (path.indexOf("/:") > -1) {
        path = path.substr(0, path.lastIndexOf("/"));
    }
    item.realpath = path;
});

export default routes;
