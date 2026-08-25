local function is_angular_project(path)
    if vim.fn.findfile('angular.json', path .. ';') ~= '' then
        return true
    end

    local package_json = vim.fn.findfile('package.json', path .. ';')
    if package_json == '' then
        return false
    end

    local ok, package = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(package_json), '\n'))
    end)
    if not ok or type(package) ~= 'table' then
        return false
    end

    local dependencies = package.dependencies or {}
    local dev_dependencies = package.devDependencies or {}
    return dependencies['@angular/core'] ~= nil or dev_dependencies['@angular/core'] ~= nil
end

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.component.html', '*.html' },
    callback = function()
        if is_angular_project(vim.fn.expand '%:p') then
            vim.bo.filetype = 'htmlangular'
        end
    end,
})
