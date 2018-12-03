/**
 * 水平分割线组件
 * 先用hr标签吧
 */
export default (self, h) => {
    return [
        h('hr', {
            style: {
                // 边距margin
                'margin-left': self.prop.inline ? (self.prop.margin ? (self.prop.margin.left ? self.prop.margin.left : '0px') : '0px') : '0px',
                'margin-right': self.prop.inline ? (self.prop.margin ? (self.prop.margin.right ? self.prop.margin.right : '0px') : '0px') : '0px',
                'margin-top': self.prop.inline ? (self.prop.margin ? (self.prop.margin.top ? self.prop.margin.top : '0px') : '0px') : '0px',
                'margin-bottom': self.prop.inline ? (self.prop.margin ? (self.prop.margin.bottom ? self.prop.margin.bottom : '0px') : '0px') : '0px'
            }
        })
    ];
};
