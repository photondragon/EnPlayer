#pragma once

#ifdef LIB_EXPORTS
#define CMAGICARRAY	__declspec(dllexport)
#else
#define CMAGICARRAY	//__declspec(dllimport)
#endif

#include <new>

template< class UNIT >
class CMAGICARRAY CMagicArray
{
public:
	CMagicArray();
	~CMagicArray();

	inline int	GetCount(){	return m_nUnitsCount;	}
	bool	Add(UNIT& unit);			//添加一个数据单元，只有分配不到内存时才会失败。
	bool	AddUnits(UNIT* units,int unitsCount);	//添加unitsCount个数据单元
	inline bool Get(UNIT& unit,int index)	//成功返回true，失败返回false
	{
		if(index<0 || index>=m_nUnitsCount)
			return false;
		unit = m_pArray[index];
		return true;
	}
	bool	Modify(int index,UNIT& newUnit);
	bool	Remove(int index,UNIT* removedUnitBuffer=0);
	inline void	Clear(){m_nUnitsCount	= 0;}	//清除所有UNITs，不删除内部缓冲区
	void	ClearAll();	//清除所有UNITs，并删除内部缓冲区
	//UNIT*	GetUnitAddressByIndex(int index);
	
private:
	int		m_nUnitsCount;	//数据单元的个数
	int		m_nArraySize;	//当前数组的大小（最多能容下的数据单元个数）
	UNIT*	m_pArray;		//数组

	bool	enlargeArrayBuffer(int needsize=0);	//扩大数组长度以容纳下needsize个数据单元。只有分配不到内存时才会失败
};

template< class UNIT >
inline CMagicArray<UNIT>::CMagicArray()
{
	m_nUnitsCount	= 0;
	m_pArray	= 0;
	m_nArraySize= 0;
}

template< class UNIT >
CMagicArray<UNIT>::~CMagicArray()
{
	if(m_pArray)
	{
		delete [] m_pArray;
		m_pArray	= 0;
	}
}

template< class UNIT >
bool CMagicArray<UNIT>::enlargeArrayBuffer(int needCapacity)
{
#define MMagicBufferMinCapacity		64
#define MMagicBufferMaxAddCapacity	65536
#define MMagicBufferMultipleMask	0xffff0000// = ~(MMagicBufferMaxAddCapacity-1)
	if(needCapacity<0)//
		return false;
	int newsize;
	if(needCapacity==0)
	{
		if(m_nArraySize<MMagicBufferMaxAddCapacity)
		{
			newsize	= m_nArraySize<<1;
			if (newsize<MMagicBufferMinCapacity)
				newsize	= MMagicBufferMinCapacity;
		}
		else
			newsize	= m_nArraySize + MMagicBufferMaxAddCapacity;
	}
	else if(needCapacity<=m_nArraySize)
		return true;
	else
	{
		if (needCapacity<=MMagicBufferMaxAddCapacity)
		{
			newsize = m_nArraySize<<1;
			if (newsize<MMagicBufferMinCapacity)
				newsize	= MMagicBufferMinCapacity;
			while (newsize<needCapacity)
				newsize <<= 1;
		}
		else//if(needCapacity>MMagicBufferMaxAddCapacity)
			newsize = (needCapacity+MMagicBufferMaxAddCapacity-1)&MMagicBufferMultipleMask;
	}
	UNIT* p;
	try
	{
		p = new UNIT[newsize];
		if (p==0)
			return false;
	}
	catch (std::exception& ex)
	{
		return false;
	}
	
	for (int i=0; i<m_nUnitsCount; i++)
		p[i]	= m_pArray[i];
	delete [] m_pArray;
	m_pArray	= p;
	m_nArraySize	= newsize;
	return true;
#undef MMagicBufferMinCapacity
#undef MMagicBufferMaxAddCapacity
#undef MMagicBufferMultipleMask
}

template< class UNIT >
bool CMagicArray<UNIT>::Add(UNIT& unit)
{
	if(m_nUnitsCount==m_nArraySize)
	{
		if(enlargeArrayBuffer()==false)
			return false;
	}
	m_pArray[m_nUnitsCount] = unit;
	m_nUnitsCount++;
	return true;
}

template< class UNIT >
bool CMagicArray<UNIT>::AddUnits(UNIT* units,int unitsCount)
{
	if(units ==0 || unitsCount<=0)
		return false;
	if(m_nUnitsCount+unitsCount>m_nArraySize)
	{
		if(enlargeArrayBuffer(m_nUnitsCount+unitsCount)==false)
			return false;
	}
	for(int i=0;i<unitsCount;i++)
		m_pArray[m_nUnitsCount+i]	= units[i];
	m_nUnitsCount += unitsCount;
	return true;
}

//template< class UNIT >
//UNIT* CMagicArray<UNIT>::GetUnitAddressByIndex(int index)
//{
//	if(index<m_nUnitsCount && index>=0)
//		return m_pArray+index;
//	return 0;
//}

template< class UNIT >
bool CMagicArray<UNIT>::Modify(int index,UNIT& newUnit)
{
	if(index<m_nUnitsCount && index>=0)
	{
		m_pArray[index]	= newUnit;
		return true;
	}
	return false;
}

template< class UNIT >
bool CMagicArray<UNIT>::Remove(int index,UNIT* removedUnitBuffer)
{
	if(index<m_nUnitsCount && index>=0)
	{
		if(removedUnitBuffer)
			*removedUnitBuffer	= m_pArray[index];
		for(int i=index+1;i<m_nUnitsCount;i++)
			m_pArray[i-1] = m_pArray[i];
		m_nUnitsCount--;
		return true;
	}
	return false;
}

template< class UNIT >
void CMagicArray<UNIT>::ClearAll()
{
	m_nUnitsCount	= 0;
	delete [] m_pArray;
	m_pArray	= 0;
	m_nArraySize= 0;
}