import cloneDeep from "lodash/cloneDeep";

let util = {};
util.process = (template, context) => {
    return template.replace(/\$\{(.*?)\}/g, (match, key) => {
        // key可能带.
        let val = cloneDeep(context);
        key.trim().split('.').forEach(element => {
            val = val[element];
        });
        return val;
    });
};
export default util;