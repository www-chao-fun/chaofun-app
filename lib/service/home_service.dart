import '../utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';

typedef OnSuccessList<T>(List<T> banners);

typedef OnFail(String message);

typedef OnSuccess<T>(T data);

class HomeService {
  // Future getCategoryData(OnSuccessList onSuccessList, {OnFail onFail}) async {
  //   try {
  //     var responseList = [];
  //     var response = await HttpUtil.instance.get(Api.HOME_FIRST_CATEGORY);
  //     if (response['errno'] == 0) {
  //       responseList = response['data'];
  //       FirstLevelListCategory firstLevelListCategory =
  //           FirstLevelListCategory.fromJson(responseList);
  //       onSuccessList(firstLevelListCategory.firstLevelCategory);
  //     } else {
  //       onFail(response['errorMessage']);
  //     }
  //   } catch (e) {
  //     print(e);
  //     onFail(Strings.SERVER_EXCEPTION);
  //   }
  // }

  // Future getSubCategoryData(
  //     Map<String, dynamic> parameters, OnSuccessList onSuccessList,
  //     {OnFail onFail}) async {
  //   try {
  //     var responseList = [];
  //     var response = await HttpUtil.instance
  //         .get(Api.HOME_SECOND_CATEGORY, parameters: parameters);
  //     if (response['errno'] == 0) {
  //       responseList = response['data'];
  //       SubCategoryListEntity subCategoryListEntity =
  //           SubCategoryListEntity.fromJson(responseList);
  //       onSuccessList(subCategoryListEntity.subCategoryEntitys);
  //     } else {
  //       onFail(response['errorMessage']);
  //     }
  //   } catch (e) {
  //     print(e);
  //     onFail(Strings.SERVER_EXCEPTION);
  //   }
  // }

  Future getHomeList(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response = await HttpUtil.instance
          .get(Api.HomeListCombine, parameters: parameters);
      print('sssss');
      print(parameters);
      print(response);

      if (response['success']) {
        // CategoryTitleEntity categoryTitleEntity =
        //     CategoryTitleEntity.fromJson(response["data"]);
        // print(response["data"]);
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      onFail('fail');
    }
  }

  Future getCommentFuture(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.listComments, parameters: parameters);
      if (response['success']) {
        // CategoryTitleEntity categoryTitleEntity =
        //     CategoryTitleEntity.fromJson(response["data"]);
        // print(response["data"]);
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future myListPosts(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.myListPosts, parameters: parameters);
      if (response['success']) {
        // CategoryTitleEntity categoryTitleEntity =
        //     CategoryTitleEntity.fromJson(response["data"]);
        // print(response["data"]);
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future myListUpvotes(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response = await HttpUtil.instance
          .get(Api.myListUpvotes, parameters: parameters);
      if (response['success']) {
        // CategoryTitleEntity categoryTitleEntity =
        //     CategoryTitleEntity.fromJson(response["data"]);
        // print(response["data"]);
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future myListSaved(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.myListSaved, parameters: parameters);
      if (response['success']) {
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future messageList(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.messageList, parameters: parameters);
      if (response['success']) {
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future getMemberInfo(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response = await HttpUtil.instance
          .get(Api.getMemberInfo, parameters: parameters);

      if (response['success']) {
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future listFocusForum(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response = await HttpUtil.instance
          .get(Api.listJoinedForums, parameters: parameters);
      var response1 = await HttpUtil.instance
          .get(Api.listFocusUser, parameters: parameters);
      List data = [];
      if (response['success'] || response1['success']) {
        List a = (response["data"] as List).cast();
        List b = (response1["data"]['users'] as List).cast();
        data.add(response["data"]);
        data.add(response1["data"]['users']);

        // data[0] = response["data"];
        // data[1] = response1["data"];

        onSuccess(data);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print('response222');
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future listTrends(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.listTrends, parameters: parameters);
      // List data = [];
      if (response['success']) {
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print('listTrends-加载失败');
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }
}
