import 'package:open_git/contract/user_follow_contract.dart';
import 'package:open_git/manager/user_manager.dart';

class UserFollowPresenter extends IUserFollowPresenter {
  @override
  getUserFollow(String userName, int page, bool isFollower, bool isFromMore) {
    if (isFollower) {
      return _getUserFollower(userName, page, isFromMore);
    } else {
      return _getUserFollowing(userName, page, isFromMore);
    }
  }

  _getUserFollowing(String userName, int page, bool isFromMore) async {
//    return UserManager.instance.getUserFollowing(userName, page, (data) {
//      if (data != null && data.length > 0) {
//        List<UserBean> list = new List();
//        for (int i = 0; i < data.length; i++) {
//          var dataItem = data[i];
//          list.add(UserBean.fromJson(dataItem));
//        }
//        if (view != null) {
//          view.setList(list, isFromMore);
//        }
//      }
//    }, (code, msg) {});
    final result = await UserManager.instance.getUserFollowing(userName, page);
    if (view != null) {
      view.setList(result, isFromMore);
    }
    return result;
  }

  _getUserFollower(String userName, int page, bool isFromMore) async {
//    return UserManager.instance.getUserFollower(userName, page, (data) {
//      if (data != null && data.length > 0) {
//        List<UserBean> list = new List();
//        for (int i = 0; i < data.length; i++) {
//          var dataItem = data[i];
//          list.add(UserBean.fromJson(dataItem));
//        }
//        if (view != null) {
//          view.setList(list, isFromMore);
//        }
//      }
//    }, (code, msg) {});
    final result = await UserManager.instance.getUserFollower(userName, page);
    if (view != null) {
      view.setList(result, isFromMore);
    }
    return result;
  }
}
