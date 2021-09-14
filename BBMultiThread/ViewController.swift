//
//  ViewController.swift
//  BBMultiThread
//
//  Created by SJXC on 2021/9/14.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.GCDTest()
        
        let str = "test"
        
    }

    
    /**
     信号量
     */
    func GCDTest() {
       //wait()方法使信号量-1，当信号量变成0，阻塞当前线程，等待信号量大于0，恢复线程
       let semaA = DispatchSemaphore.init(value: 1)
       let semaB = DispatchSemaphore.init(value: 0)
       let semaC = DispatchSemaphore.init(value: 0)
       
       //异步线程A
       DispatchQueue.global().async {
           print("开启异步线程A")
           for testNumber in 0...9 {
                //永久等待，直到Dispatch Semaphore的计数值 >= 1
               semaA.wait()
               print("*************Began:\(testNumber + 1)*************\n线程A输出==========\(testNumber)")
                //发信号，使原来的信号计数值+1
                semaB.signal()
           }
       }
       
       //异步线程B
       DispatchQueue.global().async {
           print("开启异步线程B")
           for testNumber in 0...9 {
               semaB.wait()
               print("线程B输出==========\(testNumber)")
               semaC.signal()
           }
       }
      
       //异步线程C
       DispatchQueue.global().async {
           print("开启异步线程C")
           for testNumber in 0...9 {
               semaC.wait()
               print("线程C输出==========\(testNumber)\n*************End:\(testNumber + 1)*************")
               semaA.signal()
           }
       }
   }
    
    
    //
    /**
     1.创建串行队列
     第一个参数代表队列的名称，可以任意起名
     第二个参数代表队列属于串行还是并行执行任务
     串行队列一次只执行一个任务。一般用于按顺序同步访问，但我们可以创建任意数量的串行队列，各个串行队列之间是并发的。
     并行队列的执行顺序与其加入队列的顺序相同。可以并发执行多个任务，但是执行完成的顺序是随机的。
     */
    func bb_serial() {
        //创建串行队列
        let serial = DispatchQueue(label: "serialQueue1")
                
        //创建并行队列
        let concurrent = DispatchQueue(label: "concurrentQueue1", attributes: .concurrent)
    }

    /**
     2.获取系统存在的全局队列
     Global Dispatch Queue有4个执行优先级：
     .userInitiated 高
     .default 正常
     .utility 低
     .background 非常低的优先级（这个优先级只用于不太关心完成时间的真正的后台任务）
     */
    func bb_global() {
        let globalQueue = DispatchQueue.global(qos: .default)

        let gloabalQue = DispatchQueue.global()
    }
    
    /**
     3.运行在主线程的Main Dispatch Queue
     正如名称中的Main一样，这是在主线程里执行的队列。因为主线程只有一个，所有这自然是串行队列。一起跟UI有关的操作必须放在主线程中执行。
     */
    func bb_main() {
        let mainQueue = DispatchQueue.main
        

    }
    
    /**
     4.暂停或者继续队列
     这两个函数是异步的，而且只在不同的blocks之间生效，对已经正在执行的任务没有影响。
     suspend()后，追加到Dispatch Queue中尚未执行的任务在此之后停止执行。
     而resume()则使得这些任务能够继续执行。
     */
    func bb_resume() {
        //创建并行队列
        let conQueue = DispatchQueue(label: "concurrentQueue1", attributes: .concurrent)

        //暂停一个队列
        conQueue.suspend()

        //继续队列
        conQueue.resume()
    }
    
    /**
     5.延迟执行
     */
    func bb_after() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {

        }
    }
    
    /**
     6.取消正在等待执行的Block操作
     取消正在等待执行的Block操作
     如果需要取消正在等待执行的Block操作，我们可以先将这个Block封装到DispatchWorkItem对象中，然后对其发送cancle，来取消一个正在等待执行的block。
     */
    func bb_cancel() {
        //将要执行的操作封装到DispatchWorkItem中
        let task = DispatchWorkItem { print("after!") }

        //延时2秒执行
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: task)

        //取消任务
        task.cancel()
    }
    
    /**
     7.同步异步
     */
    func bb_asyn() {
        //全局队列（并发队列）异步执行，开多个线程，一起执行
       DispatchQueue.global().async {

       }

       //全局队列（并发队列）同步执行，当前线程一个一个执行
       DispatchQueue.global().sync {

       }

       //主队列异步，开一个线程（主线程在主队列上运行），在新线程上一个一个执行
       DispatchQueue.main.async {

       }

       //延迟执行
       DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {

       }
    }
    
    /**
     8.调度组
     async(group:)：用来监视一组block对象的完成，你可以同步或异步地监视
     notify()：用来汇总结果，所有任务结束汇总，不阻塞当前线程
     wait()：等待直到所有任务执行结束，中途不能取消，阻塞当前线程
     队列组就是把任务放在DispatchGroup中（入组），当任务执行完毕时（出组），即当DispatchGroup中没有任务时，调用监听方法notify，注意：入组和出组一定要成对出现，有几个入组，就一定需要有几个出组。
     */
    func group() {
        // 创建一个队列组
        let group = DispatchGroup()

        // A任务入组
        group.enter()

        // A任务异步操作
        DispatchQueue.global().async(group: group, execute: DispatchWorkItem(block: {
            sleep(2)
            print("download task A ...")

            // 出组
            group.leave()
        }))

        // B任务入组
        group.enter()

        // B任务异步操作
        DispatchQueue.global().async(group: group, execute: DispatchWorkItem(block: {

            sleep(2)
            print("download task B ...")

            // 出组
            group.leave()

        }))
        
        // 主线程监听，只有当队列组中没有任务，才会执行闭包。如果多次调用该方法，每次都会去检查队列组中是否有任务，如果没有任务才执行
        group.notify(queue: DispatchQueue.main) {

            print("complete!")

        }
        
        //2,永久等待，直到所有任务执行结束，中途不能取消，阻塞当前线程
       group.wait()

       print("任务全部执行完成")
    }
    
    /**
     9.concurrentPerform 指定次数的Block最加到队列中
     DispatchQueue.concurrentPerform函数是sync函数和Dispatch Group的关联API。按指定的次数将指定的Block追加到指定的Dispatch Queue中，并等待全部处理执行结束。
     因为concurrentPerform函数也与sync函数一样，会等待处理结束，因此推荐在async函数中异步执行concurrentPerform函数。concurrentPerform函数可以实现高性能的循环迭代。
     */
    func bb_concurrentPerform() {
        //获取系统存在的全局队列
        let queue = DispatchQueue.global(qos: .default)

        //定义一个异步步代码块
        queue.async {

            //通过concurrentPerform，循环变量数组
            DispatchQueue.concurrentPerform(iterations: 6) {(index) -> Void in

                print(index)
            }

            //执行完毕，主线程更新
            DispatchQueue.main.async {

                print("done")
            }
        }
    }
    
    /**
     10.信号量
     DispatchSemaphore(value: )：用于创建信号量，可以指定初始化信号量计数值，这里我们默认1.
     semaphore.wait()：会判断信号量，如果为1，则往下执行。如果是0，则等待。
     semaphore.signal()：代表运行结束，信号量加1，有等待的任务这个时候才会继续执行。
     */
    func bb_semaphore() {
        //获取系统存在的全局队列
        let queue = DispatchQueue.global(qos: .default)

        //当并行执行的任务更新数据时，会产生数据不一样的情况
        for i in 1...10 {

            queue.async {

                print("\(i)")
            }
        }

        //使用信号量保证正确性
        //创建一个初始计数值为1的信号
        let semaphore = DispatchSemaphore(value: 1)

        for i in 1...10 {

            queue.async {

                //永久等待，直到Dispatch Semaphore的计数值 >= 1
                semaphore.wait()

                print("\(i)")

                //发信号，使原来的信号计数值+1
                semaphore.signal()
            }
        }
    }
}

