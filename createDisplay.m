function handle = createDisplay(width, height)
    %Calculate position of the window
    display.screen = get(0,'ScreenSize');
    display.window.width = width;
    display.window.height = height;
    display.window.x = (display.screen(3)-display.window.width)/2;
    display.window.y = (display.screen(4)-display.window.height)/2;
    %Display a figure with computed coordinates, without axis
    handle = figure('Position',[display.window.x display.window.y display.window.width display.window.height],'color',[0 .251 .4235]);
    axis off;
end