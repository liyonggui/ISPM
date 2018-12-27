import UIKit
import Charts

/// 图表cell
class ChartsCell: BaseTableViewCell {
    @IBOutlet var chartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        chartView.delegate = self
        chartView.backgroundColor = UIColor(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        chartView.doubleTapToZoomEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.delegate = self
        
        chartView.noDataText = "暂无数据"
        chartView.noDataTextColor = UIColor.gray
        chartView.noDataFont = UIFont.boldSystemFont(ofSize: 14)
        chartView.chartDescription?.text = "时间"
        chartView.chartDescription?.textColor = UIColor.red
        
        //y轴
        chartView.rightAxis.enabled = false
        let leftAxis = chartView.leftAxis
        leftAxis.labelCount = 10
        leftAxis.forceLabelsEnabled = false
        leftAxis.axisLineColor = UIColor.black
        leftAxis.labelTextColor = UIColor.black
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        leftAxis.labelPosition = .outsideChart
        leftAxis.gridColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0) //网格
        leftAxis.gridAntialiasEnabled = false;//抗锯齿
        leftAxis.axisMaximum = 1000//最大值
        leftAxis.axisMinimum = 0
        leftAxis.labelCount = 11//多少等分
        
        //x轴
        let xAxis = chartView.xAxis
        xAxis.granularityEnabled = true
        xAxis.labelTextColor = UIColor.black
        xAxis.labelFont = UIFont.systemFont(ofSize: 10.0)
        xAxis.labelPosition = .bottom
        xAxis.gridColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0)
        xAxis.axisLineColor = UIColor.black
        xAxis.labelCount = 12
        drawLineChart()
    }
    
    func drawLineChart() {
        self.addLimitLine(250, "限制线")
        let xValues = ["x1","x2","x3","x4","x5","x6","x7","x8","x9","x10","x11","x12"]
        chartView.xAxis.valueFormatter = ChartAxisValueFormatter(xValues as NSArray)
        chartView.leftAxis.valueFormatter = ChartAxisValueFormatter()
        
        var yDataArray1 = [ChartDataEntry]()
        for i in 0...xValues.count-1 {
            let y = arc4random()%1000;
            let entry = ChartDataEntry(x: Double(i), y: Double(y))
            
            yDataArray1.append(entry)
        }
        let set1 = LineChartDataSet(values: yDataArray1, label: "当周平均")
        set1.colors = [UIColor.black]
        set1.drawCirclesEnabled = false //绘制转折点
        set1.lineWidth = 1.0
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
//
        // 设置平滑
        set1.mode = .horizontalBezier
        let data = LineChartData(dataSets: [set1])
        set1.drawFilledEnabled = true
        chartView.data = data
        chartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0)
    }
    
    // 设置限制线
    func addLimitLine(_ value:Double, _ desc:String) {
        let limitLine = ChartLimitLine(limit: value, label: desc)
        //线
        limitLine.lineWidth = 1
        limitLine.lineColor = UIColor.red
        limitLine.lineDashLengths = [5.0,5.0]
        limitLine.labelPosition = .rightTop
        //文字
        limitLine.valueFont = UIFont.systemFont(ofSize: 10.0)
        limitLine.valueTextColor = UIColor.black
        limitLine.labelPosition = .rightBottom
        chartView.leftAxis.addLimitLine(limitLine)
    }

    func showMarkerView(_ value: String) {
        let marker = MarkerView(frame: CGRect(x: 20, y: 20, width: 60, height: 20))
        marker.chartView = chartView
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        label.text = value
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.gray
        label.textAlignment = .center
        marker.addSubview(label)
        chartView.marker = marker
    }
    
}

// 绘图代理
extension ChartsCell: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        MyPrint("chartValueSelected")
        self.showMarkerView("\(entry.y)")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        MyPrint("chartValueNothingSelected")
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
        
}

class ChartAxisValueFormatter: NSObject,IAxisValueFormatter {
    var values:NSArray?
    
    override init() {
        super.init()
    }
    
    init(_ values: NSArray) {
        super.init()
        self.values = values
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if values == nil {
            return "\(value)"
        }
        return values?.object(at: Int(value)) as? String ?? ""
    }
}
