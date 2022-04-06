class Api {
  //static const String BASE_URL = 'http://192.168.190.84:8080/mall-app';
  //static const String BASE_URL = 'http://192.168.190.84:8080';
//  static const String BASE_URL='http://192.168.190.35:8082/wx';
  static const String BASE_URL = 'https://chao.fun';
  static const String HOME_NAV_DATA =
      BASE_URL + '/api/get_menu?pageNum=1&order=new'; //首页数据
  static const String HomeListCombine = BASE_URL + '/api/v0/list_combine';
  static const String ChatChannelList = BASE_URL + '/api/v0/chat/listJoined';
  static const String ListForumsByTag =
      BASE_URL + '/api/list_forums_by_tag'; // 查询分类版块

  static const String listJoinedForums =
      BASE_URL + '/api/v0/user/listJoinedForums'; // 查询加入版块

  static const String deletePost = BASE_URL + '/api/delete_post'; // 查询加入版块

  static const String listFocusUser =
      BASE_URL + '/api/v0/user/listFocus'; // 查询关注用户

  static const String listFocusUserV1 =
      BASE_URL + '/api/v0/focus/list_focus'; // 查询关注用户

  static const String listFansUserV1 =
      BASE_URL + '/api/v0/focus/list_fans'; // 查询关注用户


  static const String listFollowersUserV1 =
      BASE_URL + '/api/v0/forum/listFollowers'; // 查询关注用户


  static const String ListTags =
      BASE_URL + '/api/v0/forum_tag/list_tags'; //查询全部分类

  static const String userAccountLogin = BASE_URL + '/api/login'; //账号密码登录

  static const String userRegister = BASE_URL + '/api/register'; //账号密码登录

  static const String userCodeLogin =
      BASE_URL + '/api/v0/phone/login'; //验证码登录

  static const String bindDevice =
      BASE_URL + '/api/v0/user/bindDevice'; // 绑定设备用于推送
  static const String unbindDevice =
      BASE_URL + '/api/v0/user/unbindDevice'; // 解绑设备

  static const String getUserInfo = BASE_URL + '/api/get_profile'; //获取用户信息
  static const String upReport = BASE_URL + '/api/v0/report'; //举报帖子
  static const String submitLink = BASE_URL + '/api/submit_link'; //发布链接帖子
  static const String submitImage = BASE_URL + '/api/submit_image'; //发布图片帖子
  static const String submitVideo = BASE_URL + '/api/v0/submitVideo'; //发布视频帖子

  static const String submitArticle =
      BASE_URL + '/api/v0/submit_article'; //发布文本帖子
  static const String getForumInfo = BASE_URL + '/api/get_forum_info'; //查询版块信息
  static const String joinChatChannel= BASE_URL + '/api/v0/chat/group_chat/join'; //查询版块信息
  static const String startChat = BASE_URL + '/api/v0/chat/single_chat/start'; //查询版块信息
  static const String getChatChannelInfo = BASE_URL + '/api/v0/chat/getChannelInfo'; //查询版块信息
  static const String forumPostList = BASE_URL + '/api/v0/list'; //查询版块信息
  static const String getPostInfo = BASE_URL + '/api/get_post_info'; // 获取帖子详情

  static const String listComments =
      BASE_URL + '/api/v0/list_comments'; // 获取评论列表

  static const String upvotePost = BASE_URL + '/api/upvote_post'; // 点赞

  static const String downvotePost = BASE_URL + '/api/downvote_post'; // 点踩

  static const String savePost = BASE_URL + '/api/v0/save_post'; // 收藏

  static const String joinForum = BASE_URL + '/api/join_forum'; // 加入版块

  static const String leaveForum = BASE_URL + '/api/leave_forum'; // 退出版块

  static const String focus = BASE_URL + '/api/v0/focus/focus'; // 关注用户

  static const String unfocus = BASE_URL + '/api/v0/focus/unfocus'; // 取消关注用户

  static const String myListPosts = BASE_URL + '/api/v0/me/list_posts'; // 我发布的

  static const String myListUpvotes =
      BASE_URL + '/api/v0/me/list_upvotes'; // 我点赞的

  static const String myListSaved = BASE_URL + '/api/v0/me/list_saved'; // 我收藏的

  static const String myHistory = BASE_URL + '/api/v0/user/getBrowsingHistory'; // 我收藏的

  static const String userToComment = BASE_URL + '/api/comment'; // 评论

  static const String getActivity = BASE_URL + '/api/v0/activity'; // 查询活动

  static const String messageList = BASE_URL + '/api/v0/message/list'; // 我的消息

  static const String getLatestAppVersion =
      BASE_URL + '/api/v0/app/getLatestAppVersion'; // 获取版本

  static const String setIcon = BASE_URL + '/api/v0/user/set_Icon'; // 设置头像

  static const String getMemberInfo = BASE_URL + '/api/v0/user/info'; // 获取用户信息

  static const String getMemberListPosts =
      BASE_URL + '/api/v0/user/list_posts'; // 获取用户发布帖子

  static const String getMemberListUpvotes =
      BASE_URL + '/api/v0/user/list_upvotes'; // 获取用户点赞帖子

  static const String getListComments =
      BASE_URL + '/api/v0/user/listComments'; // 获取用户评论帖子

  static const String toFocusUser = BASE_URL + '/api/v0/focus/focus'; // 关注用户

  static const String toUnFocusUser =
      BASE_URL + '/api/v0/focus/unfocus'; // 取消关注用户

  static const String getFeedbackChannel =
      BASE_URL + '/api/v0/feedback/getFeedbackChannel'; // 联系我们

  static const String toVote = BASE_URL + '/api/v0/post/vote'; // 投票

  static const String toCircusee = BASE_URL + '/api/v0/post/circusee'; // 投票围观

  static const String submitVote = BASE_URL + '/api/v0/submit_vote'; // 发布投票贴

  static const String searchPost = BASE_URL + '/api/search'; // 搜索帖子

  static const String searchUser = BASE_URL + '/api/v0/searchUser'; // 搜索用户

  static const String upvoteComment = BASE_URL + '/api/upvote_comment'; // 评论点赞

  static const String downvoteComment =
      BASE_URL + '/api/downvote_comment'; // 评论点踩

  static const String listTrends =
      BASE_URL + '/api/v0/focus/list_trends'; // 关注列表

  static const String searchForum = BASE_URL + '/api/v1/searchForum'; // 版块搜索
  // ?marker=&pageSize=40
  static const String listTag = BASE_URL + '/api/v0/forum/listTag'; // 获取标签列表

  static const String addRecommend = BASE_URL + '/api/v0/addRecommend'; // 管理员推荐

  static const String listBadges = BASE_URL + '/api/v0/badge/list'; // 管理员推荐

  static const String listPins = BASE_URL + '/api/v0/forum/listPins'; // 置顶帖

  static const String checkMessage = BASE_URL + '/api/v0/message/check'; //

  static const String addTag = BASE_URL + '/api/v0/post/addTag'; // 添加标签
  static const String removeTag = BASE_URL + '/api/v0/post/removeTag'; // 添加标签

  static const String getCode = BASE_URL + '/api/v0/phone/getCode'; // 获取验证码

  static const String phoneLogin = BASE_URL + '/api/v0/phone/login'; // 验证码登录

  static const String refreshCookie =
      BASE_URL + '/api/v0/user/refreshCookie'; // 刷新cookie

  static const String setPhone = BASE_URL + '/api/v0/user/setPhone'; // 刷新cookie

  static const String searchUserForAt = BASE_URL +
      '/api/v0/search/searchUserForAt'; //'/api/v0/searchUser'; //'/api/v0/search/searchUserForAt'; //''; //''; // 获取@的用户

  static const String list_focus =
      BASE_URL + '/api/v0/focus/list_focus'; // 我关注ed

  static const String getPushConfig =
      BASE_URL + '/api/v0/user/getPushConfig'; // 获取推送设置

  static const String setPushConfig =
      BASE_URL + '/api/v0/user/setPushConfig'; // 设置推送

  static const String collectionlist =
      BASE_URL + '/api/v0/collection/list'; // 合集列表

  static const String deleteCollection =
      BASE_URL + '/api/v0/collection/delete'; // 合集删除


  static const String collectionlistPosts =
      BASE_URL + '/api/v0/collection/listPosts'; // 合集详情

  static const String addcollection =
      BASE_URL + '/api/v0/collection/add'; // 合集详情

  static const String applyMod =
      BASE_URL + '/api/v0/apply_mod'; // 申请Mod

  static const String applyForum =
      BASE_URL + '/api/v0/apply_forum';

  static const String addCollectionPost =
      BASE_URL + '/api/v0/post/addCollection'; // 合集详情

  static const String deleteComment =
      BASE_URL + '/api/v0/delete_comment'; // 删除评论

  static const String highLightComment =
      BASE_URL + '/api/v0/highlightComment'; // 高亮评论

  static const String unHighLightComment =
      BASE_URL + '/api/v0/unHighlightComment'; // 高亮评论

  static const String checkJoin =
      BASE_URL + '/api/v0/forum/predictions_tournament/checkJoin'; // 检查是否加入竞猜

  static const String predictionsGet =
      BASE_URL + '/api/v0/forum/predictions_tournament/get';

  static const String predictlistPosts =
      BASE_URL + '/api/v0/forum/predictions_tournament/listPosts';

  static const String predictJoin =
      BASE_URL + '/api/v0/forum/predictions_tournament/join';

  static const String tablelist = BASE_URL + '/api/v0/forum/table/list';

  static const String ruleList = BASE_URL + '/api/v0/forum/listRules';

  static const String badgeList = BASE_URL + '/api/v0/badge/listForumBadges';

  static const String modList = BASE_URL + '/api/v0/mod/list';

  static const String tableget = BASE_URL + '/api/v0/forum/table/get';

  static const String httpurltitle = BASE_URL + '/api/v0/httpurl/title';

  static const String setDesc = BASE_URL + '/api/v0/user/set_desc';
  
  static const String changeUserName = BASE_URL + '/api/v0/user/changeUserName';

  // static const String addTag = BASE_URL + '/api/v0/post/addTag'; // 添加标签

}
