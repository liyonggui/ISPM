let permissionConfig = {
	sys_user: {
		add: 'sys_user:add',
		edit: 'sys:user:edit',
		delete: 'sys_user:delete'
	},

	sys_office_tree: {
		add: 'sys_office_tree:add',
		delete: 'sys_office_tree:delete',
		edit: 'sys_office_tree:edit'
	},

	sys_office: {
		add: 'sys_office:add',
		delete: 'sys_office:delete',
		edit: 'sys_office:edit'
	},

	safe_disclosure_info: {
		person: 'act:safeDisclosure:person',
		delete: 'act:safeDisclosure:delete',
		add: 'act:safeDisclosure:add',
		edit: 'act:safeDisclosure:edit',
		submit: 'act:safeDisclosure:submit'
	},

	project: {
		edit: 'sys:project:edit',
		delete: 'sys:project:delete'
	},
	safe_check: {
		add: 'safe_check:add',
		edit: 'safe_check:edit',
		view: 'safe_check:view',
		delete: 'safe_check:delete',
		rectify: 'safe_check:rectify'
	  },
	safe_safeInspection: {
		add: 'safe_safeInspection:add',
		delete: 'safe_safeInspection:delete',
		view: 'safe_safeInspection:view',
		edit: 'safe_safeInspection:edit',
		submit: 'safe_safeInspection:submit',
		preview: 'safe_safeInspection:preview',
		rectify: 'safe_safeInspection:rectify'
	},
	dangerPoint: {
		edit: 'dangerPoint:edit',
		view: 'dangerPoint:view',
		drawingAdd:'dangerPoint:drawingAdd',
		drawingEdit:'dangerPoint:drawingEdit',
		drawingView:'dangerPoint:drawingView',
		drawingDelete:'dangerPoint:drawingDelete',
		drawingDownload:'dangerPoint:drawingDownload',
		drawingPointAdd:"dangerPoint:drawingPointAdd",
		drawingRailAdd:"dangerPoint:drawingRailAdd"
	},
	safe_drawing_point: {
		add: 'safe_drawing_point:add',
		edit: 'safe_drawing_point:edit',
		view: 'safe_drawing_point:view',
		approve: 'safe_drawing_point:approve',
		qrcode_view: 'safe_drawing_point:qrcode_view',
		rectify: 'safe_drawing_point:rectify',
		delete: 'safe_drawing_point:delete',
		close: 'safe_drawing_point:close',
		consideration:'safe_drawing_point:consideration'
	},
	electric_fence_list: {
		add: 'electric_fence_list:add',
		edit: 'electric_fence_list:edit',
		view: 'electric_fence_list:view',
		approve: 'electric_fence_list:approve',
		qrcode_view: 'electric_fence_list:qrcode_view',
		rectify: 'electric_fence_list:rectify',
		delete: 'electric_fence_list:delete',
		close: 'electric_fence_list:close',
		consideration:'electric_fence_list:consideration',
	},
	dangerProject: {
		edit: 'dangerProject:edit',
		view: 'dangerProject:view',
		drawingAdd:'dangerProject:drawingAdd',
		drawingEdit:'dangerProject:drawingEdit',
		drawingView:'dangerProject:drawingView',
		drawingDelete:'dangerProject:drawingDelete',
		drawingDownload:'dangerProject:drawingDownload',
		drawingPointAdd:"dangerProject:drawingPointAdd",
		drawingRailAdd:"dangerPoint:drawingRailAdd"
	},
	danger_project_list: {
		add: 'danger_project_list:add',
		edit: 'danger_project_list:edit',
		view: 'danger_project_list:view',
		approve: 'danger_project_list:approve',
		qrcode_view: 'danger_project_list:qrcode_view',
		rectify: 'danger_project_list:rectify',
		delete: 'danger_project_list:delete',
		close: 'danger_project_list:close',
		consideration:'danger_project_list:consideration',
	},
	danger_rail_list: {
		add: 'danger_rail_list:add',
		edit: 'danger_rail_list:edit',
		view: 'danger_rail_list:view',
		approve: 'danger_rail_list:approve',
		qrcode_view: 'danger_rail_list:qrcode_view',
		rectify: 'danger_rail_list:rectify',
		delete: 'danger_rail_list:delete',
		close: 'danger_rail_list:close',
		consideration:'danger_rail_list:consideration',
	},
	safe_rectify_list: {
        // workflow: 'safe_rectify_list:workflow',
        delete: 'safe_rectify_list:delete',
        view: 'safe_rectify_list:view',
        edit: 'safe_rectify_list:edit',
        approve: 'safe_rectify_list:approve'
	},
	safe_safeInspection: {
		significant: 'safe_safeInspection:significant',
        add: 'safe_safeInspection:add',
        delete: 'safe_safeInspection:delete',
        view: 'safe_safeInspection:view',
        edit: 'safe_safeInspection:edit',
        submit: 'safe_safeInspection:submit',
        preview: 'safe_safeInspection:preview',
	},
	safe_disclosure: {
		delete: 'safeDisclosure:delete',
		add: 'safeDisclosure:add',
		edit: 'safeDisclosure:edit',
		submit: 'safeDisclosure:submit'
	},
	safe_disclosure_content: {
	  delete: 'safe:safeDisclosureContent:delete',
	  add: 'safe:safeDisclosureContent:add',
	  edit: 'safe:safeDisclosureContent:edit',
	  submit: 'safe:safeDisclosureContent:submit',
	  view:'safe:safeDisclosureContent:view',
	  import:'safe:safeDisclosureContent:import',
	  complete:'safe:safeDisclosureContent:complete'
	},
}
function initPermission(vue, store) {
	vue.prototype.$permission = permissionConfig;

	vue.prototype.$checkPermission = function (value) {
		let operationPermission = store.state.operationPermission
		if ('string' === typeof (value)) {
			let filterPermission = operationPermission.filter(item => {
				return item.permission === value
			})
			if (0 === filterPermission.length) {
				return false
			}
			else {
				return true
			}
		}
	}
}
export {
	initPermission,
	permissionConfig
}
