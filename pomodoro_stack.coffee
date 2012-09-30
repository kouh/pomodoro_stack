# Filter
angular.module('MyModule', [])
    .filter 'integer', ->
            return (input, num)->
                out = (input>>0).toString()
                while(out.length < num)
                    out = "0" + out
                return out

# Model
class Task
    constructor:(@body) ->
        @done = false
        @pomoCnt = 0

notificateToDesktop = (title ,body,timeUpSec)->
    console.log "ブラウザがデスクトップ通知機能に対応していません。"  if typeof window.webkitNotifications is "undefined"
        
    permission = webkitNotifications.checkPermission()
    switch permission # パーミッションチェック
      when 0
        notification = webkitNotifications.createNotification("tomate.gif", title, body)
        notification.onclick = (e) ->
            notification.cancel()
        
        notification.show() 
        if timeUpSec > 0
            setTimeout( ->
                notification.cancel()
            ,timeUpSec*1000)

      when 1
        webkitNotifications.requestPermission ->           
          alert "デスクトップ通知機能を設定しました"

      when 2
        alert "デスクトップ通知機能が拒否されています"

    
                
# controller
TimerCtrl = ($scope) ->
    ids = []
    
    $scope.time = new Date(0, 0, 0, 0, 0, 0)
    
    
    $scope.stop = ()->
        clearInterval i for i in ids
        ids =[]
        $scope.time = new Date(0, 0, 0, 0, 0, 0)
    
    $scope.startPomodoro = (task,min,sec)->
        startTimer(min,sec,->
            task.pomoCnt--
            
            notificateToDesktop("ポモドーロ終了", "ポモドーロが終了しました。休憩時間に入ります。",10)
            
            # 休憩
            startTimer(5,0,->
                notificateToDesktop("休憩終了", "休憩時間が終了しました。")
            )
        )
        
    startTimer =  (min,sec,onFinish)->
        clearInterval i for i in ids
        ids =[]
        $scope.time = new Date(0, 0, 0,0,min,sec)
        
        id = setInterval( ->
            $scope.time.setSeconds( $scope.time.getSeconds() - 1 )

            $scope.$apply()
            
            if $scope.time.getSeconds() is 0 and $scope.time.getMinutes() is 0
                clearInterval id
                ids=[]
                if onFinish then onFinish()
        ,1000)
        
        ids.push id
    
        
ToDoCtrl = ($scope) ->

    $scope.tasks = [
    ]  
    
    $scope.addNew = ->
        $scope.tasks.push new Task($scope.newTaskBody)
        $scope.newTaskBody = ""
    
    $scope.getDoneCount = ->
        count = 0
        angular.forEach($scope.tasks,(task)->
            count += 1  if task.done
        )
        return count
    
    $scope.deleteDone = ->
        oldTasks = $scope.tasks
        $scope.tasks=[]
        angular.forEach(oldTasks,(task)->
            if !task.done then $scope.tasks.push(task)
        )
        
    $scope.addPomodoro = (index) ->
        $scope.tasks[index].pomoCnt++
        
    $scope.deletePomodoro = (index) ->
        $scope.tasks[index].pomoCnt--   if $scope.tasks[index].pomoCnt >0
        
    $scope.startPomo = (task) ->
        $scope.startPomodoro(task,0,10) if task.pomoCnt > 0
           