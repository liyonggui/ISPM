import Vue from 'vue'
const MessageUtil = {
  save_success () {
    Vue.prototype.$message({
      message:'保存成功',
      type:'success'
    })
  },
  save_failure () {
    Vue.prototype.$message({
      message:'保存失败',
      type:'error'
    })
  },
  delete_success () {
    Vue.prototype.$message({
      message:'删除成功',
      type:'success'
    })
  },
  delete_failure () {
    Vue.prototype.$message({
      message:'删除失败',
      type:'error'
    })
  },
  update_success () {
    Vue.prototype.$message({
      message:'修改成功',
      type:'success'
    })
  },
  update_failure () {
    Vue.prototype.$message({
      message:'修改失败',
      type:'error'
    })
  },
}
export default MessageUtil
