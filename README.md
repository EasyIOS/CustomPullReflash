#CustomPullReflash

作为EasyIOS解耦下拉刷新后，自定义下拉刷新的demo实例，希望大家在此基础上可以写出更炫酷的代码，同时欢迎修改下拉刷新和上拉加载的程序源码。

使用方法：

		@weakify(self);
	    [self.tableView addPullToRefreshWithActionHandler:^{
	        @strongify(self);
	        self.sceneModel.request.page = @1;
	        self.sceneModel.active = YES;
	    } customer:YES];
	    

	    CircleView *circleView = [[CircleView alloc] initWithframe:CGRectMake(0 0 30 30) with:self.tableView];
	    [self.tableView.pullToRefreshView setCustomView:circleView];
	    
	    [self.tableView addInfiniteScrollingWithActionHandler:^{
	        @strongify(self);
	        [self.sceneModel.request.page increase:@1];
	        self.sceneModel.active = YES;
	    } customer:YES];

	    InfiniteView *infiniteView = [[InfiniteView alloc] initWithframe:CGRectMake(0 0 30 30) with:self.tableView];
	    [self.tableView.infiniteScrollingView setCustomView:infiniteView];

效果见AppStore的APP:脉冲书志

那大致就像下面这个圆圈的效果：

![image](http://code4app.qiniudn.com/photo/52be2645cb7e84cb558b4d73_1.gif)
