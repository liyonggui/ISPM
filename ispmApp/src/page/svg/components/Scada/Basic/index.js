import moment from 'moment'
export default {
  tools: [
    {
      id: 2,
      name: 'sign_type_2_2',
      config: {
        label: '多边围栏',
        width: 80,
        height: 80,
        keepRatio: true,
        permission:'dangerPoint:drawingRailAdd'  
      },
      imgUrl: '',
      params: [
        { name: 'code', label: '围栏编号',disabled:true, type: 'String', value: '', hint: '输入围栏编号' },
        { name: 'deviceId', label: '绑定设备', type: 'Enum', opts: [] },
        { name: 'rail_type', label: '围栏类型',  type: 'Enum', value: 'rail_type_1',opts: []},
        { name: 'point_property', label: '围栏性质', type: 'Enum', value: "point_property_1" , opts: [ ] },
        { name: 'status', label: '围栏状态', type: 'Enum', value: "rail_status_1" , opts: [ ] },
        { name: 'registerDate', label: '登记时间', type: 'DateTime',value:'' },
        { name: 'radius', label: '半径(米)', type: 'Int', value: '4' },
        { name: 'remarks', label: '备注', type: 'Text', value: '', hint: '输入备注信息',maxlength:500 },
        { name: 'point', label: '点', type: 'Hide', value: '' },
        { name: 'viewBox', label: 'svg视窗', type: 'Hide', value: '' },
        { name: 'auditStatus', label: '审核状态', type: 'Hide', value: 'audit_status_1' }
      ]
    },
    {
      id: 3,
      name: 'sign_type_2_1',
      config: {
        label: '圆形围栏',
        width: 20,
        height: 20,
        keepRatio: true,
        permission:'dangerPoint:drawingRailAdd'   
      },
      imgUrl: '',
      params: [
        { name: 'code', label: '围栏编号',disabled:true, type: 'String', value: '', hint: '输入围栏编号' },
        { name: 'deviceId', label: '绑定设备', type: 'Enum', opts: [] },
        { name: 'rail_type', label: '围栏类型',  type: 'Enum', value: 'rail_type_1', opts: [] },
        { name: 'point_property', label: '围栏性质', type: 'Enum', value: "point_property_1" , opts: [ ] },
        { name: 'status', label: '围栏状态', type: 'Enum', value: "rail_status_1" , opts: [ ] },
        { name: 'registerDate', label: '登记时间', type: 'DateTime', value:'' },
        { name: 'radius', label: '半径(米)', type: 'Int', value: '1' },
        { name: 'remarks', label: '备注', type: 'Text', value: '', hint: '输入备注信息',maxlength:500  },
        { name: 'auditStatus', label: '审核状态', type: 'Hide', value: 'audit_status_1' },
      
      ]
    },
    {
      id: 4,
      name: 'sign_type_1',
      config: {
        label: '危险点',
        width: 20,
        height: 20,
        keepRatio: true,
        permission:'dangerPoint:drawingPointAdd'  
      },
      imgUrl: '',
      params: [
        { name: 'code', label: '危险点编号',disabled:true, type: 'String', value: '', hint: '输入危险点编号' },
        { name: 'drawing_point_type', label: '危险点类型', type: 'Enum', value: 'drawing_point_type_1', opts: [ ] },
        { name: 'point_property', label: '危险点性质', type: 'Enum', value: "point_property_1" , opts: [ ] },
        { name: 'registerDate', label: '登记时间', type: 'DateTime', value:''},
        { name: 'status', label: '危险点状态', type: 'Enum', value: "danger_status_1" , opts: [ ] },
        { name: 'radius', label: '半径(米)', type: 'Int', value: '1' },
        { name: 'remarks', label: '备注', type: 'Text', value: '', hint: '输入备注信息',maxlength:500  },
        { name: 'auditStatus', label: '审核状态', type: 'Hide', value: 'audit_status_1' }
      ]
    },
    {
      id: 5,
      name: 'sign_type_3',
      config: {
        label: '危大工程',
        width: 20,
        height: 20,
        keepRatio: true,
        permission:'dangerProject:drawingPointAdd'  
      },
      imgUrl: '',
      params: [
        { name: 'code', label: '危大工程编号', disabled:true,type: 'String', value: '', hint: '输入危大工程编号' },
        { name: 'drawing_point_type', label: '危大工程类型', type: 'Enum', value: 'drawing_point_type_1', opts: [ ] },
        { name: 'point_property', label: '危大工程性质', type: 'Enum', value: "point_property_1" , opts: [ ] },
        { name: 'registerDate', label: '登记时间', type: 'DateTime', value:'' },
        { name: 'status', label: '危大工程状态', type: 'Enum', value: "danger_status_1" , opts: [ ] },
        { name: 'radius', label: '半径(米)', type: 'Int', value: '1' },
        { name: 'remarks', label: '备注', type: 'Text', value: '', hint: '输入备注信息' ,maxlength:500 },
        { name: 'auditStatus', label: '审核状态', type: 'Hide', value: 'audit_status_1' }
      ]
    }
  ]
}
