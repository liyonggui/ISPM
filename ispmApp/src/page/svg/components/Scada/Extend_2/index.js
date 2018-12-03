export default {
  tools: [
    {
      id: 117,
      name: 'ex-comp-4',
      config: {
        label: '员工',
        compType: 'svg',
        compSource: require('@/images/scada/svg/ex-comp-4.svg'),
        width: 48,
        height: 75,
        keepRatio: true,
        rotatable: false,
        colorMask: true
      },
      imgUrl: require('@/images/scada/svg/ex-comp-4_pre.svg'),
      params: [{ name: 'text', label: '姓名', type: 'String', value: '', hint: '将覆盖绑定' }]
    }
  ]
}
