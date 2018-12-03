/**
 * 所有的基础组件配置
 * TODO: 直接做文件夹扫描
 */
import labelConfig from './config/label';
import hrConfig from './config/hr';
import inputConfig from './config/input';
import numberinputConfig from './config/numberinput';
import radioConfig from './config/radio';
import checkboxConfig from './config/checkbox';
import switchConfig from './config/switch';
import selectConfig from './config/select';
import datepickerConfig from './config/datepicker';
import timepickerConfig from './config/timepicker';
import rateConfig from './config/rate';
import uploadConfig from './config/upload';

const components = {
    label: labelConfig,
    hr: hrConfig,
    input: inputConfig,
    numberinput: numberinputConfig,
    radio: radioConfig,
    checkbox: checkboxConfig,
    switch: switchConfig,
    select: selectConfig,
    datepicker: datepickerConfig,
    timepicker: timepickerConfig,
    rate: rateConfig,
    upload: uploadConfig
};
// map -> list
let componentsList = [];
for (let i in components) {
    componentsList.push({
        name: i,
        prop: components[i]
    });
}
export default componentsList;
