$(function() {
  var file = null;

  // アップロードするファイルを選択
  $('#userfile').change(function() {
    
    file = $(this).prop('files')[0];
    
    // ファイルが指定されていなければ何も起こらない
    if(!file) {
      return;
    }
    $("#message").text("アップロード中です");
    // ファイル名に付与する現在日時を取得
    var now = new Date();
    var year = now.getFullYear();
    var mon = ("0" + (now.getMonth() + 1)).slice(-2);
    var day = ("0" + now.getDate()).slice(-2);
    var hour = ("0" + now.getHours()).slice(-2);
    var min = ("0" + now.getMinutes()).slice(-2);
    var sec = ("0" + now.getSeconds()).slice(-2);
    var time = String(year) + String(mon) + String(day) + String(hour) + String(min) + String(sec)

    // ポリシーを発行する
    $.ajax({
      url: 'upload',
      type: 'POST',
      data: {
        content_type: file.type,
        size: file.size,
        name: file.name,
        time: time
      }
    })
    .done(function( data, textStatus, jqXHR ) {
      // 取得したポリシーをフォームデータの形に整形する
      var name, fd = new FormData();
      for (name in data.form) if (data.form.hasOwnProperty(name)) {
        fd.append(name, data.form[name]);
      }
      fd.append('file', file); // ファイルを添付
        console.log(fd);
      $.ajax({
        url: data.url,
        type: 'POST',
        dataType: 'json',
        data: fd,
        processData: false,
        contentType: false
      })
      .done(function( data, textStatus, jqXHR ) {
        console.log('success!')
        
        var name = time + "_" + $('#userfile')[0].files[0].name;
        $.ajax({
          url: 'download',
          type: 'POST',
          data: {
            name: name
          }
        })
        .done(function (data) {
          console.log('success!3');
          $("#message").text("アップロードに成功しました");
          var s3BucketName = gon.s3_bucket;
          var s3RegionName = gon.s3_region;
          var object_urls = '';
          object_urls += "https://s3-" + s3RegionName + ".amazonaws.com/" + s3BucketName + "/" + data['key'];
          $("#file_path").val(object_urls);
          $("#file_path, #save_submit").prop('disabled', false);
        }).fail(function () {
          console.log('error!3');
          $("#message").text("アップロードに失敗しました");
        })
      })
      .fail(function( jqXHR, textStatus, errorThrown ) {
        // アップロード時のエラー
        console.log('error: 2'); 
        $("#message").text("アップロードに失敗しました");
      });  

    })
    .fail(function( jqXHR, textStatus, errorThrown ) {
      // ポリシー取得時のエラー
      console.log('error: 1');
      $("#message").text("アップロードに失敗しました");
    });

  });
});