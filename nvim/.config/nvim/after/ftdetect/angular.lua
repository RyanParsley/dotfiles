-- Detect Angular template files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.component.html", "*.html" },
  callback = function()
    local path = vim.fn.expand("%:p")
    -- Check if we're in an Angular project
    if vim.fn.findfile("angular.json", path .. ";") ~= "" or
       vim.fn.findfile("package.json", path .. ";"):match("@angular") then
      vim.bo.filetype = "html.angular"
    end
  end,
})
