/**
 * 文本标签组件
 * 先用p标签吧
 */
export default (self, h) => {
    return [
        h('p', {
            domProps: {
                innerHTML: self.prop.label || '文本标签'
            },
            style: self.prop.style ? {
                'text-align': self.prop.style['text-align'],
                'font-size': self.prop.style['font-size'] + 'px',
                'font-weight': self.prop.style['font-weight'] ? 'bold' : 'none',
                'color': self.prop.style['color']
            } : {}
        })
    ];
};
