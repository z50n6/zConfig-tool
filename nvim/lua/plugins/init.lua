-- 作用: plugins 总入口，按分组导入子目录
-- 包含: core/lang/tools/ui/ai 五类插件配置
return {
  { import = "plugins.core" },
  { import = "plugins.lang" },
  { import = "plugins.tools" },
  { import = "plugins.ui" },
  { import = "plugins.ai" },
}
