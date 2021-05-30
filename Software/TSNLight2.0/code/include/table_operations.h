#ifndef TABLE_OPERATIONS_H
#define TABLE_OPERATIONS_H

#include<stdlib.h>
#include<string.h>
#include<stdio.h>


typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;



typedef struct node{
	int data;
	struct node *next;
}LNode,*LinkedList;

//匹配域（五元组）
typedef struct match_domain
{
    u32 src_ip;     //源ip地址
    u32 dst_ip;     //目的ip地址
    u16 src_port;   //源端口号
    u16 dst_port;   //目的端口号
    u8 protocol;      //协议类型
}match_domain;


typedef struct index_table_entry
{
    struct match_domain md;
    struct timeval time;
    unsigned int hit_count;
    unsigned char valid;
}index_table_entry;

typedef struct idle_id_table_entry
{
    unsigned int id;
    struct idle_id_table_entry *next;
}idle_id_table_entry;



struct tuple_rule
{
	match_domain value;
	match_domain mask;
};


// typedef struct timeval 
// {
//     long  tv_sec;         /* seconds */
//     int  tv_usec;        /* and microseconds */
// }timeval;

typedef struct table_operations
{
    struct index_table_entry *index_table; //索引表
    struct node *idle_id_table;  //空闲ID记录表
    unsigned int idle_id_count;  //空闲ID数量
    unsigned int tablesize; //表项规模
}table_operations;

table_operations init_index_table(unsigned int tablesize);

int search_index_table(table_operations tablename, match_domain md);

int cmp_tuples(match_domain key1,match_domain key2);

int insert_new_entry(table_operations *tablename, match_domain md);

int delete_entry(table_operations *tablename, match_domain md);

unsigned int get_idle_entry_num(table_operations tablename);

int get_table_entry_num (table_operations *tablename);

void print_entry_info(table_operations tablename,int entry_id);

void free_index_table(table_operations *tablename);


//头插法 
LinkedList headInsert(LinkedList *L,unsigned int tablesize);

//尾插法
LinkedList tailInsert(LinkedList *L,unsigned int tablesize);

//给第k给结点之后增加一个值x
void  add(LinkedList L, int k, int x);

//删除第k个结点
void deleteK(LinkedList L, int k);

//更改第k个结点的值为x
void update(LinkedList L, int k, int x); 

//查询第k个结点的值 
int getK(LinkedList L, int k);

//输出链表所有值 
void print(LinkedList L);

#endif