function result = pyHyp2f1(x, y)

    % 使用 system() 函数调用 Python 脚本并传递参数
    [status, result] = system(['python ', 'pyScript.py', ' ', num2str(x), ' ', num2str(y)]);

    % 检查脚本是否成功执行
    if status == 0
        % 返回脚本输出结果
        result = str2double(result);  % 将字符串转换为数值
    else
        error('Error in executing Python script');
    end
end